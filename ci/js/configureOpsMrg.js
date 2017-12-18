/**************************************************************/
/* Tested on Version 3.6                                      */
/**************************************************************/


const puppeteer = require('puppeteer');
var nconf = require('nconf');
// Then load configuration from a designated file.
nconf.file({ file: 'config.json.local' });
nconf.required(['url', 'registration', 'email']);

const OPSMGR_URL= nconf.get('url');
OPSMGR_REGISTRATION_USERNAME= nconf.get('registration:username');
OPSMGR_REGISTRATION_PASSWORD= nconf.get('registration:password');
OPSMGR_REGISTRATION_FIRSTNAME= nconf.get('registration:firstname');
OPSMGR_REGISTRATION_LASTNAME= nconf.get('registration:lastname');

OPSMGR_CONFIG_EMAIL_FROM= nconf.get('email:from');
OPSMGR_CONFIG_EMAIL_REPLYTO= nconf.get('email:replyTo');
OPSMGR_CONFIG_EMAIL_ADMIN= nconf.get('email:admin');
OPSMGR_CONFIG_EMAIL_TRANSPORT= nconf.get('email:transport');
OPSMGR_CONFIG_EMAIL_HOSTNAME= nconf.get('email:hostname');
OPSMGR_CONFIG_EMAIL_PORT= nconf.get('email:port');


(async () => {
    var OPSMGR_URL= nconf.get('url');
    const browser = await puppeteer.launch();
    const page = await browser.newPage();
    await page.goto(OPSMGR_URL);

    //Try to Login first
    //
    await page.type('#mms-body-application > div > div > section > div > div > div > div > form > fieldset:nth-child(2) > input', OPSMGR_REGISTRATION_USERNAME);
    await page.type('#mms-body-application > div > div > section > div > div > div > div > form > fieldset:nth-child(3) > input',  OPSMGR_REGISTRATION_PASSWORD);
    await page.click('#mms-body-application > div > div > section > div > div > div > div > form > footer > button');
    await page.screenshot({path: 'after_login.png'});

    console.log(page.url());

    var innerText = null;
    try{
        innerText = await page.evaluate(() => document.querySelector('#mms-body-application > div > div > section > div > div > div > div > form > div > div > span').innerText);
        console.log(innerText);
    }catch(e){}
    if(innerText != null){

        //Click on the registration link
        await page.click('#mms-body-application > div > div > section > div > div > footer > p > a');
        await page.waitForSelector('#mms-body-application > div > div > section > main > div > form > h4');
        await page.screenshot({path: 'registration.png'});
        await page.type('#emailAddress',  OPSMGR_REGISTRATION_USERNAME);
        await page.type('#password',  OPSMGR_REGISTRATION_PASSWORD);
        await page.type('#firstName',  OPSMGR_REGISTRATION_FIRSTNAME);
        await page.type('#lastName',  OPSMGR_REGISTRATION_LASTNAME);

        await page.click('#mms-body-application > div > div > section > main > div > form > fieldset:nth-child(6) > label > input[type="checkbox"]'); // single selection
        await page.screenshot({path: 'headless_true.png'});

        await page.click('#mms-body-application > div > div > section > main > div > form > footer > button');

        //Wait for the results to show up
        await page.waitForSelector('body > div > div > main > div > h1');
    }
    await page.waitFor(1000);
    await page.screenshot({path: 'step1.png'});
    var stepName = null;
    try{
        stepName = await page.evaluate(() => document.querySelector('body > div > div > main > div > div.form-view > div > form > fieldset:nth-child(1) > div.wizard-form-legend').innerText);
        console.log(stepName);
    }catch(e){}

    //Step 1 : Fill Web Server and Email details
    if(stepName && stepName.indexOf('Web Server') !==-1){
        console.log('Step 1: Configuring Web Server');
        //#httpsPEMKeyFile
        //#httpsPEMKeyFilePassword
        //#clientCertificateMode none|agents_only|required
        //#remoteIpHeader

        //EMAIL
        await page.evaluate(function(url,emailFrom,emailReplyTo,emailAdmin,emailTransport,emailHostname,emailPort){
            document.querySelector('#centralUrl').value = url;
            document.querySelector('#fromEmailAddr').value = emailFrom;
            document.querySelector('#replyToEmailAddr').value = emailReplyTo;
            document.querySelector('#adminEmailAddr').value = emailAdmin;
            document.querySelector('#mailTransport').value = emailTransport;
            document.querySelector('#mailHostname').value = emailHostname;
            document.querySelector('#mailPort').value = emailPort;

        }, OPSMGR_URL,OPSMGR_CONFIG_EMAIL_FROM,OPSMGR_CONFIG_EMAIL_REPLYTO,OPSMGR_CONFIG_EMAIL_ADMIN,OPSMGR_CONFIG_EMAIL_TRANSPORT,OPSMGR_CONFIG_EMAIL_HOSTNAME,OPSMGR_CONFIG_EMAIL_PORT);
        await page.screenshot({path: 'step1_completed.png'});
        await page.evaluate(() => {
            var a = document.querySelector("body > div > div > main > div > footer > button > span");
            var e = document.createEvent('MouseEvents');
            e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            a.dispatchEvent(e);
        });
        // #userSvcClass
        await page.waitFor('#sessionMaxHours', {timeout: 10000}); // timeout after 10s

    }else{console.log('Looks like Step1 has been already configured')}
    try{
        stepName = await page.evaluate(() => document.querySelector('body > div > div > main > div > div > div > form > fieldset > div:nth-child(1)').innerText);
        console.log(stepName);
    }catch(e){}

    await page.screenshot({path: 'step1_completed.png'});

    if(stepName && stepName.indexOf('User Authentication') !==-1){
        console.log('Step; 2: Configuring User Authentication');
        //#userSvcClass com.xgen.svc.mms.svc.user.UserSvcDb|com.xgen.svc.mms.svc.user.UserSvcLdap
        //#passwordMinChangesBeforeReuse
        //#passwordMaxFailedAttemptsBeforeAccountLock
        //#passwordMaxDaysInactiveBeforeAccountLock
        //#passwordMaxDaysBeforeChangeRequired
        //#invitationOnly true|false
        //
        //MFA
        //#multiFactorAuthLevel OFF|OPTIONAL|REQUIRED_FOR_GLOBAL_ROLES|REQUIRED
        //#multiFactorAuthAllowReset true|false
        //#multiFactorAuthIssuer


        //Other Authentication Options
        //#reCaptchaEnabled true|false
        //#sessionMaxHours

         await page.evaluate(() => {
            var a = document.querySelector("body > div > div > main > div > footer > button > span");
            var e = document.createEvent('MouseEvents');
            e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            a.dispatchEvent(e);
        });
        await page.waitFor('#poolEnabled', {timeout: 10000}); // timeout after 10s
        await page.screenshot({path: 'step2_completed.png'});

    }else{console.log('Looks like User Authentication has been already configured')}

    try{
        stepName = await page.evaluate(() => document.querySelector('body > div > div > main > div > div > div > form > fieldset > div:nth-child(1)').innerText);
        console.log(stepName);
    }catch(e){}


    if(stepName && stepName.indexOf('Server Pool') !==-1){
        console.log('Step 3: Configuring Server Pool');
        await page.evaluate(() => {
            var a = document.querySelector("body > div > div > main > div > footer > button > span");
            var e = document.createEvent('MouseEvents');
            e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            a.dispatchEvent(e);
        });

        await page.waitFor('#backupFileSystemStoreGzipCompressionLevel', {timeout: 10000}); // timeout after 10s
        await page.screenshot({path: 'step3_completed.png'});

    }else{console.log('Looks like Server Pool has been already configured')}

    try{
        stepName = await page.evaluate(() => document.querySelector('body > div > div > main > div > div > div > form > fieldset > div:nth-child(1)').innerText);
        console.log(stepName);
    }catch(e){}

    if(stepName && stepName.indexOf('Backup Snapshots') !==-1){
        console.log('Executing Step4');



        await page.evaluate(() => {

            //#backupFileSystemStoreGzipCompressionLevel -1|0|1...9
            //#interval 6|8|12|24
            //#baseRetention 2|3|4|5
            //#dailyRetention 0|3|4|5|6|7|15|30|60|90|120|180|360
            //#weeklyRetention 0|1|2|3|4|5|6|7|8|12|16|20|24|52
            //#monthlyRetention 0|1|2|3|4|5|6|7|8|9|10|11|12|13|18|24|36


            //KMIP Server Configuration
            //#backupKmipServerHost
            //#backupKmipServerPort
            //#backupKmipServerCAFile

            var a = document.querySelector("body > div > div > main > div > footer > button > span");
            var e = document.createEvent('MouseEvents');
            e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            a.dispatchEvent(e);
        });

        await page.waitFor('#proxyHost', {timeout: 10000}); // timeout after 10s

    }else{console.log('Looks like Step4 has been already configured')}

    try{
        stepName = await page.evaluate(() => document.querySelector('body > div > div > main > div > div > div > form > fieldset > div:nth-child(1)').innerText);
        console.log(stepName);
    }catch(e){}

    if(stepName && stepName.indexOf('HTTPS Proxy') !==-1){
        console.log('Step5: Configuring HTTP/HTTPS Proxy');
        await page.evaluate(() => {

            var a = document.querySelector("body > div > div > main > div > footer > button.btn.btn-primary");
            var e = document.createEvent('MouseEvents');
            e.initMouseEvent('click', true, true, window, 0, 0, 0, 0, 0, false, false, false, false, 0, null);
            a.dispatchEvent(e);
        });

        await page.waitFor('body > div > div > div > div.js-react-site-header > div > div > div.site-header-plan-details > h4', {timeout: 10000}); // timeout after 10s
        await page.screenshot({path: 'step5_completed.png'});

    }else{console.log('Looks like HTTPS Proxy has been already configured')}


   await browser.close();
})();
