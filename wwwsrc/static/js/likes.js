import Ntred from './ntred.js';



class OidcHandler {
    // --- Configuration (Extracted from backend requirements) ---
    static AUTH0_DOMAIN = "dev-ewbtot61m8ffwhvn.us.auth0.com";
    static CLIENT_ID = "CoL8M7oUkUPWBeX2S3Q3tRAp28wzFIvH";
    static BACKEND_URL = window.location.origin;

    static decodeIdToken(token) {
        try {
            // Split the JWT into [header, payload, signature]
            const parts = token.split('.');
            if (parts.length !== 3) {
                throw new Error('Invalid token structure');
            }

            // Base64url decode the payload (part 1)
            const base64Url = parts[1];
            const base64 = base64Url.replace(/-/g, '+').replace(/_/g, '/');

            // Convert the base64 string to a binary string and decode UTF-8
            const jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function (c) {
                return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
            }).join(''));

            // Return the parsed JSON claims
            return JSON.parse(jsonPayload);
        } catch (error) {
            console.error('Failed to decode ID token:', error);
            return null;
        }
    }

    static __getIntention() {
        try {
            let tmp = JSON.parse(localStorage.getItem('app_oidc__pre_login_intention'));
            if (Date.now() - tmp.time > 3600 * 1000) {
                // If old enough (1 hour)
                return null;
            } else {
                return tmp;
            }
        } catch (err) {
            return null;
        }
    };
    static __setIntention(pre_login_intention) {
        let intention = {
            action: null, param: {}, time: Date.now(),
            departure_url: window.location.pathname,
        };
        if (pre_login_intention) {
            intention = { ...intention, ...pre_login_intention }
            localStorage.setItem('app_oidc__pre_login_intention', JSON.stringify(intention));
        } else {
            localStorage.removeItem('app_oidc__pre_login_intention');
        }
    };

    // --- 1. Handle Auth0 Callback Route ---
    static handleCallback() {
        const urlParams = new URLSearchParams(window.location.search);
        const hashParams = new URLSearchParams(window.location.hash.replace(/^#/, ''));

        // Scan both standard search parameters and implicit flow hash metrics
        const idToken = urlParams.get('id_token') || hashParams.get('id_token') ||
            urlParams.get('access_token') || hashParams.get('access_token');

        console.log('idToken', idToken);
        if (idToken) {
            localStorage.setItem("auth0_id_token", idToken);
            console.log("Token intercepted and committed to localStorage.");

            let cached_intention = this.__getIntention();
            console.log('cached_intention', cached_intention);
            if (cached_intention) {
                if (cached_intention.departure_url) {
                    // window.history.replaceState({}, document.title, cached_intention.departure_url);
                    location.href = cached_intention.departure_url;
                }
            }

            // Standard URL sanitation: Strips query fields/hashes, retaining clean base route
            // const cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;
            // window.history.replaceState({}, document.title, cleanUrl);
        };
    }


    // --- 2. Authentication Flow Initiation ---
    static initiateAuth0Login(pre_login_intention) {
        this.__setIntention(pre_login_intention);
        const LANG = window.location.pathname.slice(1, 3);
        // Auth0 does not allow wildcard URI. Sad.
        // const redirectUri = encodeURIComponent(window.location.protocol + "//" + window.location.host + window.location.pathname);
        const redirectUri = encodeURIComponent(window.location.protocol + "//" + window.location.host + `/${LANG}/me/`);

        const authUrl = `https://${this.AUTH0_DOMAIN}/authorize?` +
            `response_type=id_token` +
            `&client_id=${this.CLIENT_ID}` +
            `&redirect_uri=${redirectUri}` +
            `&scope=openid%20profile%20email` +
            `&nonce=${Math.random().toString(36).substring(2)}`;

        console.log("Redirecting to Auth0 identity platform...");
        window.location.href = authUrl;
    };

    // --- 3. Protected API Network Requests ---
    static getToken() {
        const token = localStorage.getItem("auth0_id_token");
        if (!token) {
            console.log(`Missing auth0_id_token in localStorage.`);
            console.log(`Invoke OidcHandler.initiateAuth0Login() method to redirect now`);
            // alert("No token found. Please trigger the Auth0 Login flow first.");
            return null;
        }
        return token;
    }
};
window.OidcHandler = OidcHandler;
window.addEventListener('load', async function () {
    OidcHandler.handleCallback();
    if (window.__is_user_self_profile_page) {
        const token = OidcHandler.getToken();
        let approot = document.querySelector('#jsUserInfoWidget');
        console.log('token', token);
        if (token) {
            console.log('Token us found');
            let id_token_parsed = OidcHandler.decodeIdToken(token);
            approot.innerHTML = `
                <div class="flex flex-col gap-3 pb-12">
                    <div class="w-20 h-20 rounded-full" style="background: #cccccc url('${id_token_parsed.picture}') center no-repeat scroll; background-size: cover;"></div>
                    <div></div>
                    <div class="font-bold text-lg">${id_token_parsed.name}</div>
                    <div>${id_token_parsed.email}</div>
                    <div></div>
                </div>
                <div>
                    <button class="cursor-pointer inlin-block text-center text-lg bg-slate-600 text-white px-2 py-1 rounded-md min-w-40" onclick="userInfoPageLogout()">Logout</button>
                </div>
            `;
            document.querySelector('#jsUserPagePanelPleaseLogin').remove();
        } else {
            console.log('Token not found');
            document.querySelector('#jsUserLikesList').remove();
        }
    };
});







class BackendSDK {
    constructor() {
        this.baseUrl = window.location.origin;
        this.timeoutMs = 5000;
    }

    /**
     * Internal helper to fetch an ID token safely from storage
     */
    _getAuthToken() {
        // return localStorage.getItem("auth0_id_token") || "";
        return OidcHandler.getToken() || null;
    }

    /**
     * Unified request engine enforcing timeouts and consistent payload structures
     */
    async _request(endpoint, options = {}) {
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), this.timeoutMs);

        const token = this._getAuthToken();
        const headers = {
            "Content-Type": "application/json",
            ...(token ? { "Authorization": `Bearer ${token}` } : {}),
            ...options.headers
        };

        try {
            const response = await fetch(`${this.baseUrl}${endpoint}`, {
                ...options,
                headers,
                signal: controller.signal
            });

            clearTimeout(timeoutId);
            const data = await response.json();

            if (!response.ok) {
                return {
                    err: response.status,
                    result: { message: data?.error || "HTTP pipeline error status received" }
                };
            }

            return { err: 0, result: data };

        } catch (error) {
            clearTimeout(timeoutId);

            if (error.name === "AbortError") {
                return { err: -1, result: { message: `Network request timed out past ${this.timeoutMs}ms limit.` } };
            }
            return { err: -2, result: { message: error.message || "Unknown network/parsing anomaly occurred" } };
        }
    }

    /**
     * Checks if the authenticated user has already liked a specific object
     * @param {string|number} objId - Targeted object key
     */
    async has_liked_obj(objId) {
        if (!objId || String(objId).trim().length === 0) {
            return { err: -3, result: { message: "Missing required parameter target: objId" } };
        }

        const param = encodeURIComponent(String(objId).trim());
        return await this._request(`/api/like?obj_id=${param}`, { method: "GET" });
    }

    /**
     * Resolves object like metrics against multiple object targets
     * @param {Array<string|number>} objIdArr - Array of targeted IDs
     */
    async get_likes_qty(objIdArr) {
        if (!Array.isArray(objIdArr) || objIdArr.length === 0) {
            return { err: -3, result: { message: "Invalid parameters: Input must be a non-empty array." } };
        }

        const paramString = objIdArr.map(id => encodeURIComponent(String(id).trim())).join(",");
        return await this._request(`/api/likes/count?obj_id=${paramString}`, { method: "GET" });
    }

    /**
     * Resolves the verified identity metadata of the token context
     */
    async whoami() {
        return await this._request("/api/whoami", { method: "GET" });
    }

    /**
     * Resolves authenticated profile likes listing
     */
    async get_my_likes() {
        return await this._request("/api/my/likes", { method: "GET" });
    }

    /**
     * Mutates backend tracking states for user specific object interest tracking
     * @param {string|number} objId - Targeted object key
     * @param {boolean} isActive - Active preference indicator state mapping
     */
    async set_obj_like(objId, isActive) {
        if (!objId) {
            return { err: -3, result: { message: "Missing required parameter target: objId" } };
        }

        return await this._request("/api/like", {
            method: "POST",
            body: JSON.stringify({
                obj_id: String(objId),
                is_like: Boolean(isActive)
            })
        });
    }
};
// Global initialization onto target execution stack frame
window.apiSDK = new BackendSDK();


// ----- DEMO CODE -----
// Example async context execution 
// (async () => {
//     // 1. Fetch multi-id counts
//     const counts = await apiSDK.get_likes_qty([11, 22, "abc"]);
//     console.log("Counts result structure:", counts);

//     // 2. Query whoami identity mapping
//     const identity = await apiSDK.whoami();
//     if (identity.err !== 0) {
//         console.error("Auth call validation anomaly code:", identity.err, identity.result.message);
//     } else {
//         console.log("Welcome back:", identity.result.name);
//     }

//     // 3. Mark a target item liked
//     const likeStatus = await apiSDK.set_obj_like("item_99", true);
//     console.log("Like registration transaction:", likeStatus);
// })();








window.GlobalNtredStateRegistry = {};
function getState() {
    return window.GlobalNtredStateRegistry;
}


// Articles listing situations, including issue detail page.
// Hopefully we will not dynamically generate list entry nodes in DOM!
window.fetchAndShowArticlesListLikesQty = async function () {
    const obj_id_arr = [];
    document.querySelectorAll('.jsArticleSummaryShowLikesCountWidget').forEach(async node => {
        obj_id_arr.push(node.dataset.objid);
    });
    console.log('obj_id_arr', obj_id_arr);
    const likesData = await apiSDK.get_likes_qty(obj_id_arr);
    const data_dict = likesData.result.counts;
    document.querySelectorAll('.jsArticleSummaryShowLikesCountWidget').forEach(async node => {
        // obj_id_arr.push(node.dataset.objid);
        node.innerHTML = `<div class="flex flex-row gap-1 items-center">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-thumbs-up-icon lucide-thumbs-up"><path d="M15 5.88 14 10h5.83a2 2 0 0 1 1.92 2.56l-2.33 8A2 2 0 0 1 17.5 22H4a2 2 0 0 1-2-2v-8a2 2 0 0 1 2-2h2.76a2 2 0 0 0 1.79-1.11L12 2a3.13 3.13 0 0 1 3 3.88Z"/><path d="M7 10v12"/></svg>
            <div class="min-w-7 text-right">
                ${data_dict[node.dataset.objid]}
            </div>
        </div>`;
    });
}
window.addEventListener('load', window.fetchAndShowArticlesListLikesQty);



// Article detail page
window.addEventListener('load', function () {
    document.querySelectorAll('.jsArticleInteractionWidget').forEach(async node => {
        console.log('node.dataset.objid', node.dataset.objid);
        const likesData = await apiSDK.get_likes_qty([node.dataset.objid]);
        console.log('likesData.result', likesData.result);
        console.log('likesData.result.counts', likesData.result.counts[node.dataset.objid]);
        const myRelation = await apiSDK.has_liked_obj(node.dataset.objid);
        console.log('myRelation', myRelation.result.is_liked);
        const statekey = `jsArticleInteractionWidget:` + node.dataset.objid;
        GlobalNtredStateRegistry[statekey] = {
            obj_id: node.dataset.objid,
            base_qty: likesData.result.counts[node.dataset.objid],
            is_liked: myRelation.result.is_liked,
            spinlock: false,
        };
        const appLikeButton = Ntred.create(function (useEffect, app) {
            const state = getState()[statekey];
            app.useEvent('hello', (ev_params) => {
                // Force rerender trigger
            });
            async function onSetLike(new_is_liked) {
                state.spinlock = true;
                // const new_is_liked = !state.is_liked;
                // const new_is_liked = is_target_state_liked;
                let apicall = await apiSDK.set_obj_like(state.obj_id, new_is_liked);
                if (apicall.err !== 0) {
                    if (apicall.err === 401) {
                        OidcHandler.initiateAuth0Login({ action: 'like_article' });
                        return;
                    }
                    window.alert(`Something happened.`);
                } else {
                    state.is_liked = apicall.result.status === 'liked'; // Use server answer
                };
                state.spinlock = false;
                state.base_qty = apicall.result.latest_qty;
                app.ping('hello');
            };
            app.useEvent('try-consume-prelogin-intention', async (ev_params) => {
                console.log('ping ........... try-consume-prelogin-intention');
                // Special hook to consume intention
                let intention = OidcHandler.__getIntention();
                console.log('intention', intention);
                if (intention && intention.action === 'like_article') {
                    OidcHandler.__setIntention(null); // Consume intention
                    setTimeout(async () => {
                        await onSetLike(true);
                    }, 12);
                };
            });
            app.useEvent('click-toggle-like', async (ev_params) => {
                if (state.spinlock) {
                    return;
                };
                await onSetLike(!state.is_liked);
            });
            return `<div data-click="click-toggle-like" 
                        data-jsArticleInteractionWidget-inner="${node.dataset.objid}"
                        style="
                            transition: all 120ms ease;  
                            ${state.spinlock ? 'opacity: 0.2;' : ''}
                        "
                        class="flex flex-row gap-2 min-w-16 px-2 py-2 rounded-sm cursor-pointer   hover:bg-gray-100"
            >
                <div class="${state.is_liked ? 'hidden' : ''}">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-thumbs-up-icon lucide-thumbs-up"><path d="M15 5.88 14 10h5.83a2 2 0 0 1 1.92 2.56l-2.33 8A2 2 0 0 1 17.5 22H4a2 2 0 0 1-2-2v-8a2 2 0 0 1 2-2h2.76a2 2 0 0 0 1.79-1.11L12 2a3.13 3.13 0 0 1 3 3.88Z"/><path d="M7 10v12"/></svg>
                </div>
                <div class="${!state.is_liked ? 'hidden' : ''}">
                    <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="red" stroke="red" stroke-width="1.25" stroke-linecap="round" stroke-linejoin="round" class="lucide lucide-thumbs-up-icon lucide-thumbs-up"><path d="M15 5.88 14 10h5.83a2 2 0 0 1 1.92 2.56l-2.33 8A2 2 0 0 1 17.5 22H4a2 2 0 0 1-2-2v-8a2 2 0 0 1 2-2h2.76a2 2 0 0 0 1.79-1.11L12 2a3.13 3.13 0 0 1 3 3.88Z"/><path d="M7 10v12"/></svg>
                </div>
                <div>${state.base_qty}</div>
            </div>`;
        });
        window.appLikeButton_ref = appLikeButton;
        appLikeButton.mount(node);
        appLikeButton.run();
        this.setTimeout(() => appLikeButton.ping('try-consume-prelogin-intention'), 70);
        // window.appLikeButton_ref.ping('try-consume-prelogin-intention');
    });
});








// Some actions on individual pages...

window.reallyRenderUserLikesListIntoDom = async function () { // Certain page will run this function on window 'load'
    let dom_outer = document.querySelector('#jsUserLikesList');
    let dom = document.querySelector('#jsUserLikesListInner');
    let fetched_likes = await apiSDK.get_my_likes();
    console.log('fetched_likes', fetched_likes);
    if (fetched_likes.err === 0) {
        let raw_data_arr = fetched_likes.result.results;
        raw_data_arr.sort(); // Self mutating method
        console.log('raw_data_arr', raw_data_arr);
        let needed_years_dict = {};
        fetched_likes.result.results.forEach(row => {
            const year = row.obj_id.slice(0, 4);
            needed_years_dict[year] = true;
        });
        let needed_years_arr = Object.keys(needed_years_dict);
        needed_years_arr.sort();
        console.log('needed_years_arr', needed_years_arr);
        let year_dict_all = {}; // TODO: For each year
        await Promise.all(needed_years_arr.map(async (year) => {
            const response = await fetch(`/webdb/${year}.json`);
            if (!response.ok) {
                throw new Error(`Response status: ${response.status}`);
            }
            const result = await response.json();
            console.log(result);
            year_dict_all[year] = result;
        }));
        console.log('year_dict_all', JSON.stringify(year_dict_all));
        // return;
        const raw_liked_obj_id_arr = raw_data_arr.map(row => row.obj_id);
        dom.innerHTML = needed_years_arr.map(year => {
            return `
                <h3 class="pt-8 text-md h3">${year}</h3>
            ` + year_dict_all[year].filter(row => raw_liked_obj_id_arr.indexOf(row.obj_id) >= 0).map(row => {
                return `
                    <div class="max-w-200 border-b-1 border-gray-300 " style="transition: all 180ms ease;">
                        <a class="block shrink py-4 text-black no-underline"
                            style="text-decoration: none; color: black; text-align: left;"
                            href="../articles/${row.obj_id}/"
                        >
                            <div class="text-lg sans font-bold leading-5 pb-2">
                                ${row.title}
                            </div>
                            <div class="flex flex-wrap flex-col xl:flex-row xl:place-content-between items-start text-gray-600">
                                <div class="">
                                    ${row.obj_id}
                                    &nbsp;&nbsp;&nbsp;
                                    ${row.authors_simple}
                                </div>
                                <!-- Show likes count instead of state -->
                                <div class="jsArticleSummaryShowLikesCountWidget hidden" data-objid="${row.obj_id}"></div>
                            </div>
                        </a>
                    </div>
                `;
            }).join('\n');
        }).join('\n');
    } else {
    };
};
