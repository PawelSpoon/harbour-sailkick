// just to show how to run tests from a script
// not used in this project

console.log("run-tests.js started")

const { exec } = require('child_process');

exec('node ./../dist/SongKickApiJestTest.js', (error, stdout, stderr) => {
    if (error) {
        console.error(`Execution error: ${error}`);
        return;
    }
    console.log(`stdout: ${stdout}`);
    console.error(`stderr: ${stderr}`);
});

// now run testcases
/* function runTests()
{
    return new Promise(async (resolve, reject) => {
        try {
            const main = require('./../dist/SongKickApiTest.js');
            const assert = require('assert');
            main.
            /*const it = (desc, fn) => {
                try {
                    fn();
                    console.log('\x1b[32m%s\x1b[0m', `\u2714 ${desc}`);
                } catch (error) {
                    console.log('\n');
                    console.log('\x1b[31m%s\x1b[0m', `\u2718 ${desc}`);
                    console.error(error);
                }
            };

            it('should return the sum of two numbers', () => {
                assert.strictEqual(main.sum(5, 10), 15);
            });
            resolve();
        } catch (err) {
            reject(err);
        }
    });
    console.log("tests started")
}*/