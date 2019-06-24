<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukm local">


<xsl:template match="PrimaryPrelims">
	<preface>
		<xsl:apply-templates select="* except PrimaryPreamble" />
	</preface>
	<xsl:apply-templates select="PrimaryPreamble" />
	<xsl:if test="exists(PrimaryPreamble/following-sibling::node())">
		<xsl:message terminate="yes" />
	</xsl:if>
</xsl:template>

<xsl:template match="PrimaryPrelims/Title">
	<block name="title">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="PrimaryPrelims/Number">
	<block name="number">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="LongTitle">
	<longTitle>
		<p>
			<xsl:apply-templates />
		</p>
	</longTitle>
</xsl:template>

<xsl:template match="DateOfEnactment">
	<block name="DateOfEnactment">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="DateOfEnactment/DateText">
	<xsl:if test="exists(node())">
		<docDate>
			<xsl:attribute name="date">
				<xsl:variable name="this-date" as="xs:date?" select="local:parse-date(string(.))" />
				<xsl:choose>
					<xsl:when test="exists($this-date)">
						<xsl:value-of select="$this-date" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="/Legislation/ukm:Metadata/ukm:PrimaryMetadata/ukm:EnactmentDate/@Date" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<xsl:apply-templates />
		</docDate>
	</xsl:if>
</xsl:template>


<!-- preamble -->

<xsl:template match="PrimaryPreamble">
	<xsl:if test="exists(*[not(self::EnactingTextOmitted)]) or exists(EnactingTextOmitted/*)">
	<preamble>
		<xsl:apply-templates />
	</preamble>
	</xsl:if>
</xsl:template>


<xsl:template match="IntroductoryText">
	<p>
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="EnactingText">
	<formula name="EnactingText">
		<xsl:apply-templates />
	</formula>
</xsl:template>

<xsl:template match="EnactingTextOmitted">
</xsl:template>

<xsl:template match="Contents" />

</xsl:transform>
