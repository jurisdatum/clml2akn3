<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">

<xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" />

<xsl:strip-space elements="*" />

<xsl:include href="globals.xsl" />
<xsl:include href="metadata.xsl" />
<xsl:include href="context.xsl" />
<xsl:include href="prelims.xsl" />
<xsl:include href="structure.xsl" />
<xsl:include href="numbers.xsl" />
<xsl:include href="lists.xsl" />
<xsl:include href="tables.xsl" />
<xsl:include href="amendments.xsl" />
<xsl:include href="changes.xsl" />
<xsl:include href="math.xsl" />
<xsl:include href="commentaries.xsl" />


<xsl:template match="/">
	<akomaNtoso xsi:schemaLocation="http://docs.oasis-open.org/legaldocml/ns/akn/3.0 http://docs.oasis-open.org/legaldocml/akn-core/v1.0/cos01/part2-specs/schemas/akomantoso30.xsd">
		<xsl:apply-templates />
	</akomaNtoso>
</xsl:template>

<xsl:template match="Legislation">
	<act name="{ $doc-short-type }">
		<xsl:apply-templates select="*[not(self::Versions)][not(self::Resources)]" />
	</act>
</xsl:template>

<xsl:template match="Primary | Secondary">
	<xsl:apply-templates select="PrimaryPrelims | SecondaryPrelims" />
	<body xmlns:ukakn="https://www.legislation.gov.uk/namespaces/UK-AKN">
		<xsl:apply-templates select="Body | Schedules" />
	</body>
	<xsl:if test="exists(*[not(self::PrimaryPrelims) and not(self::SecondaryPrelims) and not(self::Body) and not(self::Schedules)])">
		<xsl:message terminate="yes">
			<xsl:sequence select="*/local-name()" />
		</xsl:message>
	</xsl:if>
</xsl:template>

<xsl:template match="Body">
	<xsl:apply-templates />
</xsl:template>


<!-- blocks -->

<xsl:template match="BlockText">
	<blockContainer>
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="Para | P1para | P2para | P3para | P4para | P5para | P6para | P7para">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="Text">
	<p>
		<xsl:apply-templates />
	</p>
</xsl:template>


<!-- citations and references -->

<xsl:template match="Citation">
	<xsl:if test="exists(@UpTo)">
		<xsl:message terminate="yes" />
	</xsl:if>
	<ref eId="{ @id }" href="{ @URI }" ukl:Class="{ @Class }" ukl:Year="{ @Year }" ukl:Number="{ @Number }">
		<xsl:choose>
			<xsl:when test="node()[last()][self::FootnoteRef]"><!-- uksi/1999/1750/made -->
				<xsl:variable name="fnRef" as="element()" select="node()[last()]" />
					<xsl:apply-templates select="node() except $fnRef" />
				<xsl:apply-templates select="$fnRef" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</ref>
</xsl:template>

<xsl:template match="CitationSubRef">
	<xsl:choose>
		<xsl:when test="@UpTo">
			<rref eId="{ @id }" class="subref" from="{ @URI }" upTo="{ @UpTo }" ukl:CitationRef="{ @CitationRef }">
				<xsl:apply-templates />
			</rref>
		</xsl:when>
		<xsl:otherwise>
			<ref eId="{ @id }" class="subref" href="{ @URI }">
				<xsl:apply-templates />
			</ref>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="InternalLink">
	<a href="#{ @Ref }">
		<xsl:apply-templates />
	</a>
</xsl:template>


<!-- inline -->

<xsl:template match="Emphasis">
	<i>
		<xsl:apply-templates />
	</i>
</xsl:template>

<xsl:template match="Strong">
	<b>
		<xsl:apply-templates />
	</b>
</xsl:template>

<xsl:template match="Underline">
	<u>
		<xsl:apply-templates />
	</u>
</xsl:template>

<xsl:template match="SmallCaps">
	<inline name="smallCaps">
		<xsl:apply-templates />
	</inline>
</xsl:template>

<xsl:template match="Superior">
	<sup>
		<xsl:apply-templates />
	</sup>
</xsl:template>

<xsl:template match="Inferior">
	<sub>
		<xsl:apply-templates />
	</sub>
</xsl:template>

<xsl:template match="Term">
	<term refersTo="#{local:make-term-id(.)}">
		<xsl:apply-templates />
	</term>
</xsl:template>

<xsl:template match="Abbreviation">
	<abbr>
		<xsl:if test="exists(@Expansion)">
			<xsl:attribute name="title">
				<xsl:value-of select="@Expansion" />
			</xsl:attribute>
		</xsl:if>
		<xsl:copy-of select="@xml:lang" />
		<xsl:apply-templates />
	</abbr>
</xsl:template>

<xsl:template match="Acronym">
	<abbr class="acronym">
		<xsl:if test="exists(@Expansion)">
			<xsl:attribute name="title">
				<xsl:value-of select="@Expansion" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@xml:lang" />
		<xsl:apply-templates />
	</abbr>
</xsl:template>

<xsl:template match="Definition">
	<def>
		<xsl:apply-templates />
	</def>
</xsl:template>

<xsl:template match="Character">
	<span ukl:Name = "{ @Name }">
		<xsl:choose>
			<xsl:when test="@Name = 'DotPadding'">
				<xsl:message terminate="yes" />
			</xsl:when>
			<xsl:when test="@Name = 'DotPadding'">
				<xsl:text>&#x2026;&#x2026;&#x2026;&#x2026;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'EmSpace'">
				<xsl:text>&#x2003;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'EnSpace'">
				<xsl:text>&#x2002;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'LinePadding'">
				<xsl:text>&#x0009;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'NonBreakingSpace'">
				<xsl:text>&#x00a0;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'Minus'">
				<xsl:text>&#x2212;</xsl:text>
			</xsl:when>
			<xsl:when test="@Name = 'ThinSpace'">
				<xsl:text>&#x2009;</xsl:text>
			</xsl:when>
		</xsl:choose>
	</span>
</xsl:template>


<!-- text -->

<xsl:template match="text()">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="local:should-add-punctuation-to-number(., $context)">
			<xsl:call-template name="add-punctuation-to-number" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:if test="starts-with(., ' ')">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)" />
			<xsl:if test="ends-with(., ' ')">
				<xsl:text> </xsl:text>
			</xsl:if>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- default -->

<xsl:template match="*">
	<xsl:message terminate="yes">
		<xsl:value-of select="local-name()" />
	</xsl:message>
<!-- 	<xsl:comment>
		<xsl:value-of select="local-name()" />
	</xsl:comment>
	<xsl:apply-templates /> -->
</xsl:template>


</xsl:transform>
