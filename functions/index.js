const functions = require("firebase-functions");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

exports.executeSimpleCode = functions.https.onRequest((req, res) => {
    res.set('Access-Control-Allow-Origin', '*'); // Allow all origins
    res.set('Access-Control-Allow-Methods', 'GET, POST'); // Allow specific methods
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }

    const { script, language } = req.body;

    const payload = {
        clientId: "3e01cb295a6d6dfef0c02c9b17e55845",
        clientSecret: "5c687197c742b0c669fb31a43ac4fe7abe17661de152b7fd8401397a091c9e67",
        script: script,
        stdin: "",
        language: language === 'java' ? "java" : "python3",
        versionIndex: language === 'java' ? "5" : "3",
        compileOnly: false,
    };

    fetch("https://api.jdoodle.com/v1/execute", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
    })
        .then(response => response.json())
        .then(result => {
            res.status(200).send(result);
        })
        .catch(error => {
            res.status(500).send({ error: "Code execution failed", details: error.message });
        });
});

exports.executeCode = functions.https.onRequest((req, res) => {
    res.set('Access-Control-Allow-Origin', '*'); // Allow all origins
    res.set('Access-Control-Allow-Methods', 'GET, POST'); // Allow specific methods
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }

    const { script, unitTests, className, language, methodName } = req.body;

    const fullScript = generateFullScript(script, unitTests, className, language, methodName);
    const payload = {
        clientId: "3e01cb295a6d6dfef0c02c9b17e55845",
        clientSecret: "5c687197c742b0c669fb31a43ac4fe7abe17661de152b7fd8401397a091c9e67",
        script: fullScript,
        stdin: "",
        language: language === 'java' ? "java" : "python3",
        versionIndex: language === 'java' ? "5" : "3",
        compileOnly: false,
    };

    fetch("https://api.jdoodle.com/v1/execute", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(payload),
    })
        .then(response => response.json())
        .then(result => {
            res.status(200).send(result);
        })
        .catch(error => {
            res.status(500).send({ error: "Code execution failed", details: error.message });
        });
});

function generateFullScript(userScript, unitTests, className, language, methodName) {
    const javaArgs = unitTests
        .map(test => test.input.map(input => {
            if (input.type === 'String') {
                return `"${input.value}"`;
            } if (input.type === 'Char') {
                return `'${input.value}'`;
            }
            return input.value;
        }).join(', '))
        .join('), (');

    const pythonArgs = unitTests
        .map(test => test.input.map(input => input.value).join(', '))
        .join('), (');

    if (language === 'java') {
        let script = '';

        script += `${userScript}\n`;  // User's code
        script += 'public class Main {\n';
        script += '  public static void main(String[] args) {\n';
        script += `    ${className} instance = new ${className}();\n`;
        script += '    boolean allTestsPassed = true;\n';

        unitTests.forEach((test, index) => {
            const args = test.input.map(input => inputToString(input, language)).join(', ');
            const expectedOutput = expectedOutputToString(test.expectedOutput, language);
            const comparison = test.expectedOutput.type === 'String'
                ? `instance.${methodName}(${args}).equals(${expectedOutput})`
                : `instance.${methodName}(${args}) == ${expectedOutput}`;

            script += `    boolean result${index + 1} = ${comparison};\n`;
            script += `    System.out.println("${methodName}(${escapeJavaString(args)}) == ${escapeJavaString(expectedOutput)} : " + result${index + 1});\n`;
            script += `    allTestsPassed = allTestsPassed && result${index + 1};\n`;
        });

        script += '    if (allTestsPassed) {\n';
        script += '      System.out.println("All tests passed!");\n';
        script += '    }\n';

        script += '  }\n';
        script += '}\n';

        return script;
    } if (language === 'python') {
        let script = '';

        script += `${userScript}\n`;
        script += 'if __name__ == "__main__":\n';
        script += `    instance = ${className}()\n`;
        script += '    all_tests_passed = True\n';

        unitTests.forEach((test, index) => {
            const args = test.input.map(input => inputToString(input, language)).join(', ');
            const expectedOutput = expectedOutputToString(test.expectedOutput, language);

            script += `    result${index + 1} = instance.${methodName}(${args}) == ${expectedOutput}\n`;
            script += `    print(f"${methodName}(${args}) == ${expectedOutputToString(escapeJavaString(expectedOutput))} : {str(result${index + 1}).lower()}")\n`;
            script += `    all_tests_passed = all_tests_passed and result${index + 1}\n`;
        });

        script += '    if all_tests_passed:\n';
        script += '        print("All tests passed!")\n';

        return script;
    }

    return userScript;
}

function inputToString(input, language) {
    if (language === 'java') {
        switch (input.type) {
            case 'String':
                return `"${input.value}"`;
            case 'Char':
                return `'${input.value}'`;
            default:
                return input.value;
        }
    } if (language === 'python') {
        if (input.type === 'String') {
            return `"${input.value}"`;
        }
        return input.value;
    }
}

function escapeJavaString(string) {
    return string.replace(/\\/g, '\\\\').replace(/"/g, '\\"');
}

function expectedOutputToString(expectedOutput, language) {
    if (language === 'java') {
        switch (expectedOutput.type) {
            case 'String':
                return `"${expectedOutput.value}"`;
            case 'Char':
                return `'${expectedOutput.value}'`;
            case 'Boolean':
                return expectedOutput.value.toLowerCase();
            case 'Integer':
                return expectedOutput.value;
            default:
                return expectedOutput.value;
        }
    }

    if (expectedOutput.type === 'String') {
        return `"${expectedOutput.value}"`;
    }
    return expectedOutput.value;
}

// This is in case I accidentally delete the apprentices array in an organization
// again I suppose... 
exports.syncOrganizationMembers = functions.https.onRequest(async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*'); // Allow all origins
    res.set('Access-Control-Allow-Methods', 'GET, POST'); // Allow specific methods
    res.set('Access-Control-Allow-Headers', 'Content-Type');

    if (req.method === 'OPTIONS') {
        res.status(204).send('');
        return;
    }

    const { organizationId } = req.body;
    
    if (!organizationId) {
        res.status(400).send({ error: 'Organization ID is required' });
        return;
    }

    const db = admin.firestore();
    const organizationRef = db.collection('organizations').doc(organizationId);

    const apprenticeList = [];
    try {
        const snapshot = await db.collection('users').get();

        for (const doc of snapshot.docs) {
            const user = doc.data();
            
            // check if the user's orgId is the same as the organizationId
            if (user.orgId === organizationId && user.accountType === 'apprentice' && user.id) {
                apprenticeList.push(user.id);
            }
        }
    } catch (error) {
        res.status(500).send({ error: 'Failed to fetch organization members', details: error.message });
        return;
    }

    console.log(apprenticeList);

    try {
        await organizationRef.set({ apprentices: apprenticeList }, { merge: true });
        res.status(200).send({ message: 'Organization members updated successfully' });
    } catch (error) {
        res.status(500).send({ error: 'Failed to update organization members', details: error.message });
    }
});