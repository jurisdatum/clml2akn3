<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk local">


<xsl:template match="SignedSection">
	<hcontainer name="signatures">
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="Signatory">
	<xsl:choose>
		<xsl:when test="empty(preceding-sibling::*) and empty(following-sibling::*)">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:otherwise>
			<hcontainer name="signatureGroup">
				<xsl:apply-templates />
			</hcontainer>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="Signatory/Para">
	<intro>
		<xsl:apply-templates />
	</intro>
</xsl:template>

<xsl:template match="Signee">
	<hcontainer name="signature">
		<content>
			<xsl:apply-templates />
		</content>
	</hcontainer>
</xsl:template>

<xsl:template match="PersonName">
	<block name="signee">
		<person refersTo="#">
			<xsl:apply-templates />
		</person>
	</block>
</xsl:template>

<xsl:template match="JobTitle">
	<block name="jobTitle">
		<role refersTo="#">
			<xsl:apply-templates />
		</role>
	</block>
</xsl:template>

<xsl:template match="Department">
	<block name="department">
		<organization refersTo="#">
			<xsl:apply-templates />
		</organization>
	</block>
</xsl:template>

<xsl:template match="Address">
	<blockContainer uk:name="address" class="address">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="AddressLine">
	<p>
		<location refersTo="#">
			<xsl:apply-templates />
		</location>
	</p>
</xsl:template>

<xsl:template match="DateSigned">
	<block name="date">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:template match="DateSigned/DateText">
	<date date="{ ../@Date }">
		<xsl:attribute name="date">
			<xsl:choose>
				<xsl:when test="../@Date castable as xs:date">
					<xsl:value-of select="../@Date" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:parse-date(.)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates />
	</date>
</xsl:template>

<xsl:template match="LSseal">
	<xsl:choose>
		<xsl:when test="@ResourceRef">
			<img class="seal" src="" />
		</xsl:when>
		<xsl:when test="@Date">
			<date class="seal" date="{ @Date }">
				<xsl:apply-templates />
			</date>
		</xsl:when>
		<xsl:when test="text()">
			<inline name="seal">
				<xsl:apply-templates />
			</inline>
		</xsl:when>
		<xsl:otherwise>
			<marker name="seal" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

</xsl:transform>