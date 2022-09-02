var express = require('express');
var app     = express();
app.use(express.static('public'));

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

app.get('/querytip', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/tipct.sh ',
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send('<pre>'
                    + stdout.toString()
                    + '</pre>');
            }
            else
            {
                console.log('tipct error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/createwallet', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/createwallet.sh '
        + req.query.walletname,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send('<pre>'
                    + stdout.toString()
                    + '</pre>');
            }
            else
            {
                console.log('createwallet error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

app.get('/cekbalance', function(req, rsp)
{
    const { exec } = require('child_process');
    exec('sh sh/cekbalance.sh '
        + req.query.walletaddress,
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send('<pre>'
                    + stdout.toString()
                    + '</pre>');
            }
            else
            {
                console.log('cekbalance error:',
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
        + req.query.metadataJson.trim().split("\"").join("\\\"") + '"',
        (error, stdout, stderr) =>
        {
            console.log(stdout);
            console.log(stderr);
            if(error == null)
            {
                rsp.send('<pre>'
                    + stdout.toString()
                    + '</pre>');
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
                rsp.send('<pre>'
                    + stdout.toString()
                    + '</pre>');
            }
            else
            {
                console.log('retrieveMetadata error:',
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
                rsp.send('<pre>'
                    + stdout.toString()
                    + '</pre>');
            }
            else
            {
                console.log('submitTransfer error:',
                            error);
                rsp.send(error.toString());
            }
        });
});

