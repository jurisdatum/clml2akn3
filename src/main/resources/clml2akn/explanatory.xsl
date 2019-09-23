<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	exclude-result-prefixes="xs">


<xsl:template match="ExplanatoryNotes">
	<blockContainer class="explanatoryNotes">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="Comment">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Comment/Para">
	<xsl:choose>
		<xsl:when test="empty(preceding-sibling::*) and empty(following-sibling::*)">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:otherwise>
			<container name="para">
				<xsl:apply-templates />
			</container>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Comment/Para/Text">
	<block name="comment">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="ExplanatoryNotes//P1group | ExplanatoryNotes//P3 | ExplanatoryNotes//P4 | ExplanatoryNotes//P[P3]">
	<blockContainer class="{ local-name() }">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="ExplanatoryNotes//UnorderedList[@Class='Definition']" priority="1">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<blockList class="definition">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('blockList', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</blockList>
</xsl:template>


<!-- earlier orders -->

<xsl:template match="EarlierOrders">
	<blockContainer class="earlierOrders">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

</xsl:transform>
