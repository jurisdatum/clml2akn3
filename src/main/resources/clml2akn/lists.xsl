<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">


<xsl:template match="UnorderedList | OrderedList">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<blockList>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('blockList', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</blockList>
</xsl:template>

<xsl:template match="ListItem">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<item>
		<xsl:choose>
			<xsl:when test="exists(@NumberOverride)">
				<num>
					<xsl:choose>
						<xsl:when test="exists(parent::*/@Type) and exists(parent::*/@Decoration)">
							<xsl:value-of select="local:format-list-number(., parent::*/@Type, parent::*/@Decoration)" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="@NumberOverride" />
						</xsl:otherwise>
					</xsl:choose>
				</num>
			</xsl:when>
			<xsl:when test="parent::OrderedList">
				<xsl:variable name="num" as="xs:string">
					<xsl:choose>
						<xsl:when test="parent::*/@Type = 'alpha'">
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="a" />
						</xsl:when>
						<xsl:when test="parent::*/@Type = 'roman'">
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="i" />
						</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<num>
					<xsl:value-of select="local:format-list-number($num, parent::*/@Decoration)" />
				</num>
			</xsl:when>
		</xsl:choose>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('item', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</item>
</xsl:template>

<xsl:template match="UnorderedList[@Class='Definition']">
	<xsl:apply-templates mode="definition" />
</xsl:template>

<xsl:template match="ListItem" mode="definition">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<hcontainer name="definition">
		<content>
			<xsl:apply-templates>
				<xsl:with-param name="context" select="('content', 'definition', $context)" tunnel="yes" />
			</xsl:apply-templates>
		</content>
	</hcontainer>
</xsl:template>

</xsl:transform>
