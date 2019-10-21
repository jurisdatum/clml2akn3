<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
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
						<xsl:when test="parent::*/@Type = 'arabic'">
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="1" />
						</xsl:when>
						<xsl:when test="parent::*/@Type = 'roman'">
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="i" />
						</xsl:when>
						<xsl:when test="parent::*/@Type = 'romanupper'">
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="I" />
						</xsl:when>
						<xsl:when test="parent::*/@Type = 'alpha'">
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="a" />
						</xsl:when>
						<xsl:when test="parent::*/@Type = 'alphaupper'">
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="A" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:number value="count(preceding-sibling::ListItem) + 1" format="1" />
						</xsl:otherwise>
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
	<xsl:choose>
		<xsl:when test="$context[1] = 'blockContainer'">
			<tblock class="definition">
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('tblock', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</tblock>
		</xsl:when>
		<xsl:otherwise>
			<hcontainer name="definition">
				<xsl:choose>
					<xsl:when test="empty(*[not(self::Para)]) and exists(Para/OrderedList[@Decoration='parens'][@Type='alpha'])">
						<xsl:variable name="children" as="element()+" select="Para/*" />
						<xsl:variable name="sublist" as="element(OrderedList)" select="($children/self::OrderedList[@Decoration='parens'][@Type='alpha'])[1]" />
						<xsl:variable name="index" as="xs:integer" select="local:get-first-index-of-node($sublist, $children)" />
						<xsl:variable name="intro" as="element()*" select="$children[position() lt $index]" />
						<xsl:variable name="wrap-up" as="element()*" select="$children[position() gt $index]" />
						<xsl:if test="exists($intro)">
							<intro>
								<xsl:apply-templates select="$intro" />
							</intro>
						</xsl:if>
						<xsl:apply-templates select="$sublist/*" mode="paragraph" />
						<xsl:if test="exists($wrap-up)">
							<wrapUp>
								<xsl:apply-templates select="$wrap-up" />
							</wrapUp>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<content>
							<xsl:apply-templates>
								<xsl:with-param name="context" select="('content', 'definition', $context)" tunnel="yes" />
							</xsl:apply-templates>
						</content>
					</xsl:otherwise>
				</xsl:choose>
			</hcontainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ListItem" mode="paragraph">
	<paragraph>
		<num>
			<xsl:choose>
				<xsl:when test="parent::*/@Decoration = 'parens'">
					<xsl:text>(</xsl:text>
				</xsl:when>
			</xsl:choose>
			<xsl:number value="count(preceding-sibling::ListItem) + 1" format="a" />
			<xsl:choose>
				<xsl:when test="parent::*/@Decoration = 'parens'">
					<xsl:text>)</xsl:text>
				</xsl:when>
			</xsl:choose>
		</num>
		<xsl:call-template name="hcontainer-body" />
	</paragraph>
</xsl:template>

</xsl:transform>
