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
<!--    <xsl:import href="./tei-transcrispt.xsl"/>-->
    
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
        <xsl:value-of select="normalize-space(string-join(.//tei:titleStmt//tei:title/text(), ' '))"/>
    </xsl:variable>
    <xsl:variable name="IIIFEndpoint" select="'https://id.acdh.oeaw.ac.at/digitarium/facs/'"></xsl:variable>

    <xsl:template match="/">
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            
            <body class="page">
                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/openseadragon.min.js"/>
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div style="padding: 4em;">                        
                        <div class="card" data-index="true" id="indexme">
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
                                    <xsl:variable name="imgContainerId">
                                        <xsl:value-of select="concat('img__', position())"/>
                                    </xsl:variable>
                                    <div class="row">
                                        <div class="col-md-5">
                                            <xsl:apply-templates select="."/>
                                        </div>
                                        <div class="col-md-7">
                                            
                                                    <div style="width:80%; height:80%">
                                                        <xsl:attribute name="id">
                                                            <xsl:value-of select="$imgContainerId"/>
                                                        </xsl:attribute>
                                                    </div>
                                                    
                                                    <script type="text/javascript">
                                                        var source = "<xsl:value-of select="concat($IIIFJSON, '?format=iiif')"/>";
                                                        OpenSeadragon({
                                                        id: "<xsl:value-of select="$imgContainerId"/>",
                                                        tileSources: [{
                                                        type: 'image',
                                                        url:  source,
                                                        }],
                                                        sequence: false,
                                                        prefixUrl:"https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.2/images/"
                                                        });
                                                    </script>

                                            <p><a href="{$IIIFJSON}"><xsl:value-of select="$IIIFJSON"/></a></p>
                                            </div>
                                    </div>
                                </xsl:for-each>
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
    <xsl:template match="tei:p">
        <p><xsl:apply-templates/></p>
    </xsl:template>
</xsl:stylesheet>