<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">


<xsl:function name="local:should-add-punctuation-to-number" as="xs:boolean">
	<xsl:param name="text" as="text()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:choose>
		<xsl:when test="empty($text/parent::Pnumber)">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="exists($text/parent::Pnumber/parent::P1)">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="matches(normalize-space($text), '^\d+[A-Z]?$')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="matches(normalize-space($text), '^[a-z]+$')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template name="add-punctuation-to-number">
		<xsl:if test="starts-with(., ' ')">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>(</xsl:text>
		<xsl:value-of select="normalize-space(.)" />
		<xsl:if test="ends-with(., ' ')">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:text>)</xsl:text>
</xsl:template>

<xsl:function name="local:format-list-number" as="xs:string?">
	<xsl:param name="number" as="xs:string" />
	<xsl:param name="list-decor" as="attribute(Decoration)" />
	<xsl:choose>
		<xsl:when test="$list-decor = 'none'">
			<xsl:value-of select="$number" />
		</xsl:when>
		<xsl:when test="$list-decor = 'parens'">
			<xsl:value-of select="concat('(', $number, ')')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'parenRight'">
			<xsl:value-of select="concat($number, ')')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'brackets'">
			<xsl:value-of select="concat('[', $number, ']')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'bracketRight'">
			<xsl:value-of select="concat($number, ']')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'period'">
			<xsl:value-of select="concat($number, '.')" />
		</xsl:when>
		<xsl:when test="$list-decor = 'colon'">
			<xsl:value-of select="concat($number, ':')" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:format-list-number" as="xs:string?">
	<xsl:param name="item" as="element(ListItem)" />
	<xsl:param name="list-type" as="attribute(Type)" />
	<xsl:param name="list-decor" as="attribute(Decoration)" />
	<xsl:choose>
		<xsl:when test="exists($item/@NumberOverride)">
			<xsl:value-of select="local:format-list-number(string($item/@NumberOverride), $list-decor)" />
		</xsl:when>
	</xsl:choose>
</xsl:function>

</xsl:transform>
