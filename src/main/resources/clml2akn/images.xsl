<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl local">


<xsl:template match="Figure">
	<tblock class="figure">
		<xsl:if test="exists(@Orientation)">
			<xsl:attribute name="ukl:Orientation">
				<xsl:value-of select="@Orientation" />
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="exists(@ImageLayout)">
			<xsl:attribute name="ukl:ImageLayout">
				<xsl:value-of select="@ImageLayout" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</tblock>
</xsl:template>

<xsl:function name="local:pt-to-px" as="xs:integer">
	<xsl:param name="pt" />
	<xsl:variable name="pixels-in-a-point" as="xs:decimal" select=".75" />
	<xsl:value-of select="xs:integer(round($pt div $pixels-in-a-point))" />
</xsl:function>

<xsl:template match="Image">
	<xsl:variable name="src" as="xs:string" select="key('id',@ResourceRef)/ExternalVersion/@URI" />
	<p>
		<img src="{ $src }">
			<xsl:if test="exists(@Width)">
				<xsl:choose>
					<xsl:when test="@Width = 'auto'" />
					<xsl:when test="ends-with(@Width, 'pt')">
						<xsl:attribute name="width">
							<xsl:value-of select="local:pt-to-px(number(substring-before(@Width,'pt')))" />
						</xsl:attribute>
						<xsl:attribute name="ukl:Width">
							<xsl:value-of select="@Width" />
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="width">
							<xsl:value-of select="@Width" />
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<xsl:if test="exists(@Height)">
				<xsl:choose>
					<xsl:when test="@Height = 'auto'" />
					<xsl:when test="ends-with(@Height, 'pt')">
						<xsl:attribute name="height">
							<xsl:value-of select="local:pt-to-px(number(substring-before(@Height,'pt')))" />
						</xsl:attribute>
						<xsl:attribute name="ukl:Height">
							<xsl:value-of select="@Height" />
						</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
						<xsl:attribute name="height">
							<xsl:value-of select="@Height" />
						</xsl:attribute>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
		</img>
	</p>
</xsl:template>

</xsl:transform>
