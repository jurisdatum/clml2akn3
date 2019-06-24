<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs math local">


<xsl:template match="Formula">
	<tblock class="formula">
		<xsl:apply-templates />
	</tblock>
</xsl:template>

<xsl:template match="Formula/math:*">
	<foreign>
		<xsl:next-match />
	</foreign>
</xsl:template>

<xsl:template match="math:math">
	<xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
		<xsl:copy-of select="@*"/>
		<xsl:if test="../@AltVersionRefs">
			<xsl:variable name="version" select="key('id', ../@AltVersionRefs)" />
			<xsl:variable name="res-id" select="$version/Figure/Image/@ResourceRef | $version/Image/@ResourceRef" />
			<xsl:variable name="url" select="key('id', $res-id)/ExternalVersion/@URI" />
			<xsl:if test="exists($url)">
				<xsl:attribute name="altimg">
					<xsl:value-of select="$url" />
				</xsl:attribute>
			</xsl:if>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="math:*">
	<xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
		<xsl:copy-of select="@*"/>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>


<xsl:template match="Where">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
