<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://dse-static.foo.bar"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/tei-facsimile.xsl"/>
    <xsl:import href="./partials/osd-container.xsl"/>
    <xsl:import href="./partials/person.xsl"/>
    <xsl:import href="./partials/place.xsl"/>
    <xsl:import href="./partials/org.xsl"/>
    <xsl:import href="./tei-transcript.xsl"/>
    
    <xsl:variable name="prev">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="next">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@next), '/')[last()], '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="teiSource">
        <xsl:value-of select="data(tei:TEI/@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="link">
        <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="doc_title">
        <xsl:value-of select=".//tei:title[@type='label'][1]/text()"/>
    </xsl:variable>
    <xsl:variable name="IIIFEndpoint" select="'https://id.acdh.oeaw.ac.at/digitarium/facs/'"></xsl:variable>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            
            <body class="page">
                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/openseadragon.min.js"/>
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">                        
                        <div class="card" data-index="true">
                            <div class="card-header">
                                <div class="row">
                                    <div class="col-md-2">
                                        <xsl:if test="ends-with($prev,'.html')">
                                            <h1>
                                                <a>
                                                    <xsl:attribute name="href">
                                                        <xsl:value-of select="$prev"/>
                                                    </xsl:attribute>
                                                    <i class="fas fa-chevron-left" title="prev"/>
                                                </a>
                                            </h1>
                                        </xsl:if>
                                    </div>
                                    <div class="col-md-8">
                                        <h1 align="center">
                                            <xsl:value-of select="$doc_title"/>
                                        </h1>
                                        <h3 align="center">
                                            <a href="{$teiSource}">
                                                <i class="fas fa-download" title="show TEI source"/>
                                            </a>
                                        </h3>
                                    </div>
                                    <div class="col-md-2" style="text-align:right">
                                        <xsl:if test="ends-with($next, '.html')">
                                            <h1>
                                                <a>
                                                    <xsl:attribute name="href">
                                                        <xsl:value-of select="$next"/>
                                                    </xsl:attribute>
                                                    <i class="fas fa-chevron-right" title="next"/>
                                                </a>
                                            </h1>
                                        </xsl:if>
                                    </div>
                                </div>
                            </div>
                            <div class="card-body">
                                <xsl:for-each select=".//tei:body//tei:div[@type='page']">
                                    <xsl:variable name="pageId">
                                        <xsl:value-of select="@xml:id"/>
                                    </xsl:variable>
                                    <xsl:variable name="facsId">
                                        <xsl:value-of select="concat('facs_', @n)"/>
                                    </xsl:variable>
                                    <xsl:variable name="IIIFJSON">
                                        <xsl:value-of select="concat($IIIFEndpoint, replace(data(.//ancestor::tei:TEI//tei:surface[@xml:id=$facsId]/tei:graphic/@url), 'anno:', ''))"/>
                                    </xsl:variable>
                                    <div class="row">
                                        <div class="col-md-5">
                                            <xsl:apply-templates/>
                                        </div>
                                        <div class="col-md-7">
                                            <div class="card">
                                                <div class="card-body">
                                                    <div style="width:600px; height:800px">
                                                        <xsl:attribute name="id">
                                                            <xsl:value-of select="concat('img', $pageId)"/>
                                                        </xsl:attribute>
                                                    </div>
                                                    
                                                    <script type="text/javascript">
                                                        var source = "<xsl:value-of select="concat($IIIFJSON, '?format=iiif')"/>";
                                                        OpenSeadragon({
                                                        id: "<xsl:value-of select="concat('img', $pageId)"/>",
                                                        tileSources: [{
                                                        type: 'image',
                                                        url:  source,
                                                        }],
                                                        sequence: false,
                                                        prefixUrl:"https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.2/images/"
                                                        });
                                                    </script>
                                                </div>
                                                <div class="card-footer">
                                                    <a>
                                                        <xsl:attribute name="href"><xsl:value-of select="$IIIFJSON"/></xsl:attribute>
                                                        <xsl:value-of select="$IIIFJSON"/>
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </xsl:for-each>
                                <!--<div class="row">
                                    <div class="col-md-6">
                                        <xsl:apply-templates select="//tei:div[@type='page'] | //tei:front"/>
                                    </div>
                                    <div class="col-md-6">
                                        <h2>images</h2>
                                    </div>
                                </div>-->
                                
                            </div>
                            <div class="card-footer">
                            </div>
                        </div>                       
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>