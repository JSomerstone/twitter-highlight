
require('dotenv').config()
const lambda = require("../query");

test('User is found', () => {
    return lambda.handler({}).then(({ body }) => {
        const result = JSON.parse(body)
        expect(result.user.screen_name).toBe("JSomerstone")
        expect(result.tweets.length).toBeGreaterThan(1)
    });
});