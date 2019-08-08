<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukakn="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl ukakn local">


<xsl:template match="BlockAmendment">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<p>
		<mod>
			<quotedStructure ukl:TargetClass="{ @TargetClass }" ukl:TargetSubClass="{ @TargetSubClass }" ukl:Context="{ @Context }" ukl:Format="{ @Format }">
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('quotedStructure', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</quotedStructure>
		</mod>
		<xsl:apply-templates select="following-sibling::*[1][self::AppendText]" mode="force" />
	</p>
</xsl:template>

<xsl:template match="AppendText" />

<xsl:template match="AppendText" mode="force">
	<inline name="AppendText">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Text[exists(InlineAmendment)]">
	<p>
		<mod>
			<xsl:apply-templates />
		</mod>
	</p>
</xsl:template>

<xsl:template match="InlineAmendment">
	<quotedText>
		<xsl:apply-templates />
	</quotedText>
</xsl:template>

<xsl:template match="FragmentNumber | FragmentTitle">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
