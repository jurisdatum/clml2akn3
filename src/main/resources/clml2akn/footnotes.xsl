<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:html="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs html">


<xsl:template match="FootnoteRef">
	<noteRef href="#{@Ref}" class="footnote">
		<xsl:attribute name="marker">
			<xsl:variable name="footnote" select="key('id', @Ref)" />
			<xsl:choose>
				<xsl:when test="$footnote/Number">
					<xsl:value-of select="$footnote/Number" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="number(substring(@Ref , 2))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</noteRef>
</xsl:template>

<xsl:template match="Footnote">
	<note>
		<xsl:attribute name="class">
			<xsl:text>footnote</xsl:text>
			<xsl:if test="ancestor::html:table">
				<xsl:text> table</xsl:text>
			</xsl:if>
		</xsl:attribute>
		<xsl:attribute name="eId">
			<xsl:value-of select="@id" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'note'" tunnel="yes" />
		</xsl:apply-templates>
	</note>
</xsl:template>

<xsl:template match="FootnoteText">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
