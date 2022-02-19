<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <!-- copy elements and attributes -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- replace para nodes within an orderedlist with their content -->     
    <xsl:template match ="tei:w">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match ="tei:pc">
        <xsl:value-of select="."/>
    </xsl:template>
</xsl:stylesheet>