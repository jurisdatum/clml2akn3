<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk ukl local">


<xsl:key name="change" match="Addition[not(ancestor::Footnote)] | Repeal[not(ancestor::Footnote)] | Substitution[not(ancestor::Footnote)]" use="@ChangeId" />
<!-- What to do in case all changes for a @ChangeId are within a footnote, e.g., eudr/1995/1 -->

<xsl:template match="Addition | Substitution">
	<ins>
		<xsl:call-template name="change" />
	</ins>
</xsl:template>

<xsl:template match="Repeal">
	<del>
		<xsl:call-template name="change" />
	</del>
</xsl:template>

<xsl:template name="change">
	<xsl:variable name="first" as="element()?" select="key('change', @ChangeId)[1]" />
	<xsl:variable name="last" as="element()?" select="key('change', @ChangeId)[last()]" />
	<!-- exists($first) is necessary to guard againt the case in which all changes for this @ChangeId are within a footnote, e.g., eudr/1995/1 -->
	<xsl:variable name="is-first" as="xs:boolean" select="exists($first) and . is $first" />
	<xsl:variable name="is-last" as="xs:boolean" select="exists($last) and . is $last" />
	<xsl:variable name="classes" as="xs:string*">
		<xsl:if test="self::Substitution">
			<xsl:sequence select="lower-case(local-name())" />
		</xsl:if>
		<xsl:if test="$is-first">
			<xsl:sequence select="'first'" />
		</xsl:if>
		<xsl:if test="$is-last">
			<xsl:sequence select="'last'" />
		</xsl:if>
	</xsl:variable>
	<xsl:if test="exists($classes)">
		<xsl:attribute name="class">
			<xsl:value-of select="string-join($classes, ' ')" />
		</xsl:attribute>
	</xsl:if>
	<xsl:apply-templates select="@ChangeId" />
	<xsl:apply-templates select="@CommentaryRef" />
	<xsl:if test="$first and exists(@CommentaryRef)">	<!-- exists(@CommentaryRef) for ukpga/1980/9 -->
		<noteRef uk:name="commentary" href="#{ @CommentaryRef }" class="commentary" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="@ChangeId">
	<xsl:attribute name="ukl:ChangeId">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@CommentaryRef">
	<xsl:attribute name="ukl:CommentaryRef">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

</xsl:transform>
