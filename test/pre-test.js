// Node.js script
// run asynchroniously -> use promises and/or sync methods
// does following
// 1. clear dist folder
// 2. convert src files and store them in dist folder
// 3. copy test files to dist folder
// 4. run tests (this step may be removed and done with jest)
// it may make sense to move add this as script to package.json

console.log(process.cwd());

const fs = require('fs');
const util = require('util');

// Promisify the fs functions
const readdir = util.promisify(fs.readdir);
const unlink = util.promisify(fs.unlink);

// Function to clear the dist folder
function clearDistFolder() {
    return new Promise(async (resolve, reject) => {
        try {
            const files = await readdir('./dist');
            for (const file of files) {
                await unlink('./dist/' + file);
            }
            resolve();
        } catch (err) {
            reject(err);
        }
    });
}

(async () => {
    try {
        await clearDistFolder();
        console.log('Dist folder cleared');
        copyFiles();
        console.log('Files copied');
        //runTests();
    } catch (err) {
        console.error('An error occurred:', err);
    }
})();

const { exec } = require('child_process');

// now run testcases
function runTests() {
    console.log("starting tests");
    exec('node ./dist/run-tests.js', (error, stdout, stderr) => {
        if (error) {
            console.error(`Execution error: ${error}`);
            return;
        }
        console.log(`stdout: ${stdout}`);
        console.error(`stderr: ${stderr}`);
    });
}

function copyFiles() {
    // copy all needed src files to dis folder 
    try {
        var filename = "SongKickApi.js";

        // Read the file
        data = fs.readFileSync('./qml/' + filename, 'utf8');

        // Replace the lines
        //let result = data.replace(/\.import "Persistance.js" as DB;"/g, "const Conv = require('./SongKickApiConversion.js');");
        let result = data.replace(/\.import "Persistance\.js" as DB;/g, "const DB = require('./Persistance.js');");
        result = result.replace(/\.import "SongKickApiConversion\.js" as Conv;/g, "const Conv = require('./SongKickApiConversion.js');");
        result = result + '\n module.exports = { getUsersUpcommingEvents, getUsersTrackedItems } ;';
        // Write the result to a new file
        fs.writeFileSync('./dist/' + filename, result, 'utf8', function(err) {
            if (err) return console.log(err);
        });
        console.log('SongKickApi.js was copied to destination.txt');

        var filename2 = "SongKickApiConversion.js";
        // Read the file
        data = fs.readFileSync('./qml/' + filename2, 'utf8');

        // Replace the lines
        result = data.replace(/\.pragma library/g, '');
        result = result + '\n module.exports.convertEvent = convertEvent; \n module.exports.convertCalendarEntry = convertCalendarEntry;';
        // Write the result to a new file
        fs.writeFileSync('./dist/' + filename2, result, 'utf8');
        
        // create dummy Persistance file
        let result3 = 'function getRandom()   {  return "io09K9l3ebJxmxe2"  }'
        result3 = result3 + '\n module.exports.getRandom = getRandom;';
        fs.writeFileSync('./dist/Persistance.js', result3, 'utf8');

        // copy test starter script
        fs.copyFileSync('./test/run-tests.js', './dist/run-tests.js');
        console.log('test starter was copied to destination.txt');
        // copy test files to dist folder
        // fs.copyFileSync('./../test/SongKickApiTest.js', './../dist/SongKickApiTest.js');
        fs.copyFileSync('./test/SongKickApiJestTest.js', './dist/SongKickApiJestTest.js');
        console.log('test was copied to destination.txt');

    } catch (err) {
    };
}

