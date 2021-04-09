<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk html local">

<xsl:key name="footnote-ref" match="FootnoteRef" use="@Ref" />

<xsl:function name="local:footnote-has-ref" as="xs:boolean">
	<xsl:param name="footnote" as="element(Footnote)" />
	<xsl:sequence select="exists($footnote/@id) and exists(key('footnote-ref', $footnote/@id, root($footnote)))" />
</xsl:function>

<xsl:template match="FootnoteRef">
	<xsl:choose>
		<xsl:when test="empty(preceding::FootnoteRef[@Ref=current()/@Ref])">
			<xsl:variable name="footnote" as="element()?" select="key('id', @Ref)" />
			<authorialNote class="footnote"> <!-- uk:name="footnote"  -->
				<xsl:attribute name="eId">
					<xsl:value-of select="$footnote/@id" />
				</xsl:attribute>
				<xsl:attribute name="marker">
					<xsl:choose>
						<xsl:when test="exists($footnote/Number)">
							<xsl:value-of select="normalize-space($footnote/Number)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="number(substring(@Ref , 2))" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates select="$footnote/node()">
					<xsl:with-param name="context" select="'authorialNote'" tunnel="yes" />
				</xsl:apply-templates>
			</authorialNote>
		</xsl:when>
		<xsl:otherwise>
			<noteRef href="#{@Ref}" uk:name="footnote" class="footnote">
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
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="FootnoteText">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
