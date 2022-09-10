function togglePanel(name)
{
    const elementName = name.toLowerCase().replace(" ", "").replace("-", "");
    const panelTitle  = document.getElementById(elementName + "Title");
    const panelPanel  = document.getElementById(elementName + "Panel");
    if(panelPanel.style.display === "none")
    {
        panelTitle.innerHTML     = "▾ <u>" + name + "</u>";
        panelPanel.style.display = "block";
    }
    else
    {
        panelTitle.innerHTML     = "▸ <u>" + name + "</u>";
        panelPanel.style.display = "none";
    }
}

function setMetadataJson()
{
    const schemaJson   = document.getElementById("schemaJson").value;
    const metadataJson = document.getElementById("metadataJson");
    // metadataJson.focus();
    
    const now = new Date();
    var yyyy  = now.getFullYear();
    var MM    = now.getMonth() + 1;
    var dd    = now.getDate();
    if(MM.toString().length < 2) MM = `0${MM}`;
    if(dd.toString().length < 2 < 10) dd = `0${dd}`;
    
    if(schemaJson === "--json-metadata-detailed-schema")
    {
        var HH = now.getHours();
        var mm = now.getMinutes();
        if(HH.toString().length < 2) HH = `0${HH}`;
        if(mm.toString().length < 2) mm = `0${mm}`;
        // metadataJson.scrollIntoView();
        metadataJson.style.height = "426px";
        metadataJson.value        =
`{\r\
    "${yyyy}${MM}${dd}${HH}${mm}":\r\
    {\r\
        "map":\r\
        [\r\
            {\r\
                "k":\r\
                {\r\
                    "string": "ToDo Item 1"\r\
                },\r\
                "v":\r\
                {\r\
                    "string": "Book Flight Tickets"\r\
                }\r\
            },\r\
            {\r\
                "k":\r\
                {\r\
                    "string": "status"\r\
                },\r\
                "v":\r\
                {\r\
                    "string": "completed"\r\
                }\r\
            }\r\
        ]\r\
    }\r\
}`;
    }
    else
    {
        metadataJson.style.height = "96px";
        metadataJson.value        =
`{\r
    "${yyyy}${MM}${dd}": {\r
        "name": "Hello, World!",\r
        "completed": 1\r
    }\r
}`;
    }
    
    // const sel = metadataJson.innerHTML.length;
    // metadataJson.setSelectionRange(sel, sel);
}