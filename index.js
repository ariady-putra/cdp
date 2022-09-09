var express = require('express');
var app     = express();
app.use(express.static('public'));

var head =
'<html>\
    <head>\
        <title>Cardano Tools</title>\
        <link rel="icon" type="image/x-icon" href="img/Cardano-RGB_Logo-Icon-Blue.png">\
        <link rel="stylesheet" href="css/cdp.css"/>\
    </head>\
    <body>\
        <center>\
            <table height="100%">\
                <tr>\
                    <td valign="center">\
                        <div class="badCafe" style="width:100%">\
                            <hr/><center><h1>';
var body =                  '</h1></center><hr/>\
                        </div><br/><pre>';
var tail =              '</pre>\
                    </td>\
                </tr>\
            </table>\
        </center>\
    </body>\
</html>';

var server = app.listen(41506, function()
{
    var host = server.address().address;
    var port = server.address().port;
    console.log('Listening port:', port);
});

app.get('/', function(req, rsp)
{
    rsp.sendFile('public/index.html');
});

app.get('/queryTip', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/tipct.sh ',
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + "Query Tip"
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('tipct error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/createWallet', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/createWallet.sh '
        + req.query.walletName,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + req.query.walletName
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('createWallet error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/checkBalance', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/checkBalance.sh '
        + req.query.wallet,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + req.query.wallet
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('checkBalance error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/transfer', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/transfer.sh '
        + req.query.walletNameSrc + ' '
        + req.query.walletNameDst + ' '
        + req.query.lovelaces,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + "Transfer " + req.query.lovelaces + " Lovelaces "
                    + "from " + req.query.walletNameSrc
                    + " to " + req.query.walletNameDst
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('submitTransfer error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/transferBuildRaw', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/transferBuildRaw.sh '
        + req.query.walletNameSrc   + ' '
        + req.query.walletNameDst   + ' '
        + req.query.lovelaces       + ' '
        + req.query.minutes,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + "Transfer " + req.query.lovelaces + " Lovelaces "
                    + "from " + req.query.walletNameSrc
                    + " to " + req.query.walletNameDst
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('submitTransferBuildRaw error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/transferMultiwitness', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/transferMultiwitness.sh '
        + req.query.walletNameSrc1  + ' '
        + req.query.walletNameSrc2  + ' '
        + req.query.walletNameDst   + ' '
        + req.query.walletNameChg   + ' '
        + req.query.lovelaces,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + "Transfer " + req.query.lovelaces + " Lovelaces "
                    + " to " + req.query.walletNameDst
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('submitTransferMultiwitness error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/transferAtomicSwap', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/transferAtomicSwap.sh '
        + req.query.walletName1 + ' '
        + req.query.walletName2 + ' '
        + req.query.lovelaces1  + ' '
        + req.query.lovelaces2,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + "Swapping " + req.query.walletName1
                    +   " and "   + req.query.walletName2
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('submitTransferAtomicSwap error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/createMultisigWallet', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/createMultisigWallet.sh '
        + req.query.walletName1 + ' '
        + req.query.walletName2 + ' '
        + req.query.walletName3 + ' '
        + req.query.minutes,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + req.query.walletName1
                    + req.query.walletName2
                    + req.query.walletName3
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('createMultisigWallet error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/transferMultisig', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/transferMultisig.sh '
        + req.query.walletNameMultisig  + ' '
        + req.query.walletNameDst       + ' '
        + req.query.lovelaces           + ' '
        + req.query.witness1            + ' '
        + req.query.witness2            + ' '
        + req.query.witness3            + ' '
        + req.query.minutes,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + "Transfer " + req.query.lovelaces + " Lovelaces "
                    + "from " + req.query.walletNameMultisig
                    + " to " + req.query.walletNameDst
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('submitMultisigTransfer error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/submitMetadata', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/submitMetadata.sh '
        + req.query.walletName  + ' "'
        + req.query.metadataJson.trim().split("\"").join("\\\"") + '" '
        + req.query.schemaJson,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + req.query.walletName
                    + body
                    + (stderr.trim().length == 0 ? stdout : stderr).toString()
                    + tail);
            }
            else
            {
                console.log('submitMetadata error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/retrieveMetadata', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/retrieveMetadata.sh '
        + req.query.metadataKey,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send(head
                    + req.query.metadataKey
                    + body
                    + stdout.toString()
                    + tail);
            }
            else
            {
                console.log('retrieveMetadata error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

