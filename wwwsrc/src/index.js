import { createRemoteJWKSet, jwtVerify } from "jose";

const jsonResponse = (data, status = 200) => {
    return new Response(JSON.stringify(data), {
        status,
        headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*"
        }
    });
}

async function requireAuth(request, env) {
    const authHeader = request
        .headers
        .get("Authorization");

    if (!authHeader
        ?.startsWith("Bearer ")) {
        return null;
    }

    const token = authHeader.slice(7);

    // const issuer = `https://${env.AUTH0_DOMAIN}/`;
    const issuer = `https://dev-ewbtot61m8ffwhvn.us.auth0.com/`;

    const jwks = createRemoteJWKSet(new URL(`${issuer}.well-known/jwks.json`));

    try {
        const { payload } = await jwtVerify(token, jwks, {
            issuer,
            // audience: env.AUTH0_CLIENT_ID,
            audience: `CoL8M7oUkUPWBeX2S3Q3tRAp28wzFIvH`,
        });

        return payload;
    } catch { return null; }
}

export default {
    async fetch(request, env) {
        const url = new URL(request.url);
        const method = request.method;

        // CORS preflight
        if (method === "OPTIONS") {
            return new Response(null, {
                headers: {
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
                    "Access-Control-Allow-Headers": "Authorization, Content-Type"
                }
            });
        }

        // ================================================== API ROUTES
        // ==================================================
        if (url.pathname.startsWith("/api/")) {
            // Reusable queries
            const __getObjCountsMap = async function (objIds) {
                const placeholders = objIds.map(() => "?").join(", ");
                const { results } = await env.DB
                    .prepare(`
                            SELECT obj_id, COUNT(*) AS count
                            FROM user_likes
                            WHERE obj_id IN (${placeholders})
                            GROUP BY obj_id
                        `)
                    .bind(...objIds) // Spread the array into the bind function
                    .all();
                const countsMap = {};
                console.log('objIds ... ', objIds);
                objIds.forEach(id => countsMap[id] = 0);
                results.forEach(row => {
                    countsMap[row.obj_id] = row.count;
                });
                return countsMap;
            }


            // ---------------------------------------------- Public endpoint: GET
            // /api/likes/count?obj_id=11,22,33,44 ----------------------------------------------
            if (url.pathname === "/api/likes/count" && method === "GET") {
                const objIdParam = url.searchParams.get("obj_id");

                if (!objIdParam) {
                    return jsonResponse({
                        error: "Missing obj_id"
                    }, 400);
                }

                // 1. Split the comma-separated string into an array of trimmed IDs
                const objIds = objIdParam.split(",").map(id => id.trim()).filter(Boolean);

                if (objIds.length === 0) {
                    return jsonResponse({
                        error: "Invalid obj_id format"
                    }, 400);
                }

                try {

                    return jsonResponse({
                        counts: await __getObjCountsMap(objIds)
                    });
                } catch (err) {
                    return jsonResponse({
                        error: err?.message ?? "Database error"
                    }, 500);
                }
            }

            // ---------------------------------------------- Everything below requires
            // authentication ----------------------------------------------
            const payload = await requireAuth(request, env);

            if (!payload?.sub) {
                return jsonResponse({
                    error: "Unauthorized"
                }, 401);
            }
            if (!payload?.email) {
                return jsonResponse({
                    error: "Unauthorized",
                    msg: "You must have an address"
                }, 401);
            }

            // const userId = payload.sub;
            const userId = payload.email;


            // ----------------------------------------------
            // GET /api/whoami
            // Returns claims from the verified Auth0 ID token
            // ----------------------------------------------
            if (
                url.pathname === "/api/whoami" &&
                method === "GET"
            ) {
                if (!payload?.sub) {
                    return jsonResponse(
                        {
                            error: "Unauthorized"
                        },
                        401
                    );
                }

                return jsonResponse({
                    sub: payload.sub,
                    email: payload.email ?? null,
                    name: payload.name ?? null,
                    email_verified:
                        payload.email_verified ?? null,
                    picture: payload.picture ?? null,

                    // Useful debugging fields
                    iss: payload.iss,
                    aud: payload.aud,
                    iat: payload.iat,
                    exp: payload.exp,

                    // Everything Auth0 supplied
                    claims: payload
                });
            }

            // ---------------------------------------------- GET /api/my/likes
            // ----------------------------------------------
            if (url.pathname === "/api/my/likes" && method === "GET") {
                try {
                    const result = await env.DB
                        .prepare(`
                            SELECT
                                obj_id,
                                created_at
                            FROM user_likes
                            WHERE user_id = ?
                            ORDER BY created_at DESC
                        `)
                        .bind(userId)
                        .all();

                    return jsonResponse({
                        results: result?.results ?? []
                    });
                } catch (err) {
                    return jsonResponse({
                        error: err
                            ?.message ?? "Database error"
                    }, 500);
                }
            }

            // ---------------------------------------------- POST /api/like body: {
            // "obj_id": "...",   "is_like": true }
            // ----------------------------------------------
            if (url.pathname === "/api/like" && method === "POST") {
                try {
                    const body = await request.json();
                    const objId = body?.obj_id;
                    const isLike = body?.is_like;
                    if (typeof objId !== "string" || objId.length === 0) {
                        return jsonResponse({
                            error: "Missing obj_id"
                        }, 400);
                    }

                    if (isLike === true) {
                        await env
                            .DB
                            .prepare(`
                            INSERT OR IGNORE
                            INTO user_likes
                            (
                                user_id,
                                obj_id
                            )
                            VALUES (?, ?)
                            `)
                            .bind(userId, objId)
                            .run();

                        console.log('await __getObjCountsMap([objId])', await __getObjCountsMap([objId]));
                        return jsonResponse({
                            success: true, status: "liked",
                            // Also get latest canonical likes quantity
                            latest_qty: (await __getObjCountsMap([objId]))[objId],
                        });
                    }

                    await env
                        .DB
                        .prepare(`
                        DELETE FROM user_likes
                        WHERE
                            user_id = ?
                            AND obj_id = ?
                        `)
                        .bind(userId, objId)
                        .run();



                    // Send response
                    return jsonResponse({
                        success: true, status: "unliked",
                        // Also get latest canonical likes quantity
                        latest_qty: (await __getObjCountsMap([objId]))[objId],
                    });
                } catch (err) {
                    return jsonResponse({
                        error: err
                            ?.message ?? "Invalid request"
                    }, 400);
                }
            }

            // ---------------------------------------------- 
            // GET /api/like?obj_id=...
            // ----------------------------------------------
            if (url.pathname === "/api/like" && method === "GET") {
                try {
                    // Extract obj_id from the URL query parameters
                    const objId = url.searchParams.get("obj_id");

                    if (!objId || objId.trim().length === 0) {
                        return jsonResponse({
                            error: "Missing obj_id parameter"
                        }, 400);
                    }

                    // Query the database to check if the like relationship exists
                    const result = await env.DB.prepare(`
                        SELECT 1 
                        FROM user_likes 
                        WHERE user_id = ? AND obj_id = ?
                        LIMIT 1
                    `)
                        .bind(userId, objId)
                        .first(); // .first() returns the row object or null if not found

                    // If a row is returned, they liked it. Otherwise, they didn't.
                    const isLiked = result !== null;

                    return jsonResponse({
                        success: true,
                        is_liked: isLiked
                    });
                } catch (err) {
                    return jsonResponse({
                        error: err?.message ?? "Invalid request"
                    }, 500); // Internal server error for DB failures
                }
            }

            return jsonResponse({
                error: "Not Found"
            }, 404);
        }

        // ================================================== STATIC ASSETS
        // ==================================================
        if (env.ASSETS) {
            return env
                .ASSETS
                .fetch(request);
        }

        return new Response("Not Found", { status: 404 });
    }
};
