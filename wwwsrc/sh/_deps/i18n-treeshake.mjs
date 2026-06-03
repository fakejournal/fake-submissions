// Copyright (c) 2026 Neruthes.
// Permission is granted to use this script as part of building workflow of the website of Fake Journal.



import { load } from "cheerio";

/**
 * @param {string} html - input HTML (already rendered from EJS etc.)
 * @param {string} lang - target locale (e.g. "en", "ja")
 * @returns {Promise<string>}
 */
async function buildLocalizedHtml(html, lang) {
    const $ = load(html, { decodeEntities: false });

    // 1. Remove elements not matching i18n-for
    $("[i18n-for]").each((_, el) => {
        const allowed = ($(el).attr("i18n-for") || "")
            .split(",")
            .map(s => s.trim());

        if (!allowed.includes(lang)) {
            $(el).remove();
        }
    });

    // 2. Handle data-i18n text replacement
    $("[data-i18n]").each((_, el) => {
        const raw = $(el).attr("data-i18n");
        if (!raw) return;

        const map = Object.fromEntries(
            raw.split("|").map(pair => {
                const [k, v] = pair.split(":");
                return [k?.trim(), v?.trim()];
            })
        );

        if (map[lang]) {
            $(el).text(map[lang]);
        }

        $(el).removeAttr("data-i18n");
    });

    // 3. Handle attr-<lang>-<attr>
    $("*").each((_, el) => {
        const attribs = el.attribs || {};

        Object.keys(attribs).forEach(attrName => {
            const match = attrName.match(/^attr-([a-zA-Z0-9_-]+)-(.+)$/);
            if (!match) return;

            const [, attrLang, realAttr] = match;

            if (attrLang === lang) {
                $(el).attr(realAttr, attribs[attrName]);
            }

            // always remove the helper attr
            $(el).removeAttr(attrName);
        });
    });

    // 4. Remove i18n-for attributes (cleanup)
    $("[i18n-for]").removeAttr("i18n-for");

    return $.html();
}










import fs from 'fs';

const locales = ["en", "zh"];

for (const LANG of locales) {
    const taskInner = async function (from_tmpl, to_file, flag__removeRootWrap) {
        const template = fs.readFileSync(from_tmpl).toString();
        let localized = await buildLocalizedHtml(template, LANG);
        localized = localized.replace(/\<\/?(partial)\>/g, '');
        if (flag__removeRootWrap) {
            localized = localized.replace(/\<\/?(head|body|html)\>/g, '');
        };
        fs.writeFileSync(to_file, localized);
    };

    function inplace(from_tmpl) { return taskInner(from_tmpl, from_tmpl, false); }; // Keep html/head/body, shake DOM in-place


    const listofhtmlpaths = fs.readFileSync('.tmp/wwwdistallhtmlpathslist.txt').toString();
    listofhtmlpaths.trim().split('\n').forEach(function (file_path) {
        if (file_path.indexOf(`wwwdist/${LANG}/`) === 0) {
            inplace(file_path);
        }
    });



};


