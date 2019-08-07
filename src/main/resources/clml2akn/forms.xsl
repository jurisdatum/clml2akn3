<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">


<xsl:template match="Form">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<tblock class="form">
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('tblock', $context)" />
		</xsl:apply-templates>
	</tblock>
</xsl:template>

<xsl:template match="Form/IncludedDocument">
	<xsl:variable name="resource" as="element(Resource)" select="key('id', @ResourceRef)" />
	<xsl:variable name="uri" as="xs:anyURI" select="$resource/ExternalVersion/@URI" />
	<p>
		<img src="{ $uri }" />
	</p>
</xsl:template>

</xsl:transform>
