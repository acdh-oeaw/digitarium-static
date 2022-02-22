<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#"
    version="2.0" exclude-result-prefixes="#all">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:template match="/">
        <xsl:variable name="constants">
            <xsl:for-each select=".//node()[parent::acdh:RepoObject]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="TopColId">
            <xsl:value-of select="data(.//acdh:TopCollection/@rdf:about)"/>
        </xsl:variable>
        <rdf:RDF xmlns:acdh="https://vocabs.acdh.oeaw.ac.at/schema#">
            <acdh:TopCollection>
                <xsl:attribute name="rdf:about">
                    <xsl:value-of select=".//acdh:TopCollection/@rdf:about"/>
                </xsl:attribute>
                <xsl:copy-of select="$constants"/>
                <xsl:for-each select=".//node()[parent::acdh:TopCollection]">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </acdh:TopCollection>
            
            
            <xsl:for-each select=".//node()[parent::acdh:MetaAgents]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select=".//acdh:Collection">
                <acdh:Collection>
                    <xsl:attribute name="rdf:about"><xsl:value-of select="@rdf:about"/></xsl:attribute>
                    <xsl:copy-of select="$constants"/>
                    <xsl:for-each select=".//node()">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </acdh:Collection>
            </xsl:for-each>
            <xsl:for-each select="collection('../data/editions')//tei:TEI">

                <xsl:variable name="partOf">
                    <xsl:value-of select="concat(@xml:base, '/editions')"/>
                </xsl:variable>
                <xsl:variable name="id">
                    <xsl:value-of select="concat($TopColId, '/', @xml:id)"/>
                </xsl:variable>
                <acdh:Resource rdf:about="{$id}">
                    <!--<acdh:hasPid><xsl:value-of select=".//tei:idno[@type='handle']/text()"/></acdh:hasPid>-->
                    <acdh:hasTitle xml:lang="de"><xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>, <xsl:value-of select=".//tei:title[@type='num'][1]/text()"/></acdh:hasTitle>
                    <acdh:hasAccessRestriction rdf:resource="https://vocabs.acdh.oeaw.ac.at/archeaccessrestrictions/public"/>
                    <acdh:hasCategory rdf:resource="https://vocabs.acdh.oeaw.ac.at/archecategory/text/tei"/>
                    <acdh:hasLanguage rdf:resource="https://vocabs.acdh.oeaw.ac.at/iso6393/deu"/>
                    <acdh:isPartOf rdf:resource="{$partOf}"/>
                    <acdh:hasCoverageStartDate rdf:datatype="http://www.w3.org/2001/XMLSchema#date"><xsl:value-of select="replace(replace(@xml:id, '.xml', ''), 'ed__', '')"/></acdh:hasCoverageStartDate>
                    <xsl:copy-of select="$constants"/>
                </acdh:Resource>
                <xsl:for-each select=".//tei:graphic">
                    <xsl:variable name="facsId">
                        <xsl:value-of select="replace(@url, 'anno:', '')"/>
                    </xsl:variable>
                    <xsl:variable name="facsUrl">
                        <xsl:value-of select="concat($TopColId, '/facs/', substring-before($facsId, '-'), '/', $facsId)"/>
                    </xsl:variable>
                    <acdh:Resource rdf:about="{$facsUrl}">
                        <acdh:hasTitle xml:lang="de"><xsl:value-of select="$facsId"/></acdh:hasTitle>
                        <acdh:isSourceOf rdf:resource="{$id}"/>
                        <!--<acdh:hasCoverage xml:lang="de"><xsl:value-of select="$datum"/></acdh:hasCoverage>-->
                        <acdh:hasAccessRestriction rdf:resource="https://vocabs.acdh.oeaw.ac.at/archeaccessrestrictions/public"/>
                        <acdh:hasCategory rdf:resource="https://vocabs.acdh.oeaw.ac.at/archecategory/image"/>
                        <acdh:isPartOf rdf:resource="{concat($TopColId, '/facs')}"/>
                        <xsl:copy-of select="$constants"/>
                    </acdh:Resource>
                </xsl:for-each>
            </xsl:for-each>
        </rdf:RDF>
    </xsl:template>   
</xsl:stylesheet>