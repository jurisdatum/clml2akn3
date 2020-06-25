<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
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
<xsl:include href="images.xsl" />
<xsl:include href="amendments.xsl" />
<xsl:include href="citations.xsl" />
<xsl:include href="forms.xsl" />
<xsl:include href="footnotes.xsl" />
<xsl:include href="signatures.xsl" />
<xsl:include href="explanatory.xsl" />
<xsl:include href="changes.xsl" />
<xsl:include href="math.xsl" />
<xsl:include href="commentaries.xsl" />
<xsl:include href="resources.xsl" />


<xsl:template match="/">
	<akomaNtoso xsi:schemaLocation="http://docs.oasis-open.org/legaldocml/ns/akn/3.0 http://docs.oasis-open.org/legaldocml/akn-core/v1.0/cos01/part2-specs/schemas/akomantoso30.xsd">
		<xsl:namespace name="uk">
			<xsl:text>https://www.legislation.gov.uk/namespaces/UK-AKN</xsl:text>
		</xsl:namespace>
		<xsl:apply-templates />
	</akomaNtoso>
</xsl:template>

<xsl:template match="Legislation">
	<act name="{ $doc-short-type }">
		<xsl:apply-templates select="*[not(self::Footnotes) and not(self::Versions) and not(self::Resources)]" />
	</act>
</xsl:template>

<xsl:template match="Primary">
	<xsl:apply-templates select="PrimaryPrelims" />
	<body>
		<xsl:call-template name="add-internal-id-if-necessary">
			<xsl:with-param name="from" select="Body" />
		</xsl:call-template>
		<xsl:apply-templates select="Body | Appendix | Schedules" />
	</body>
	<xsl:if test="exists(ExplanatoryNotes | Include)">
		<conclusions>
			<xsl:apply-templates select="ExplanatoryNotes | Include" />
		</conclusions>
	</xsl:if>
	<xsl:if test="exists(*[not(self::PrimaryPrelims) and not(self::Body) and not(self::Appendix) and not(self::Schedules) and not(self::ExplanatoryNotes) and not (self::Include)])">
		<xsl:message terminate="yes">
			<xsl:sequence select="*/local-name()" />
		</xsl:message>
	</xsl:if>
</xsl:template>

<xsl:template match="Secondary">
	<xsl:apply-templates select="SecondaryPrelims" />
	<body>
		<xsl:call-template name="add-internal-id-if-necessary">
			<xsl:with-param name="from" select="Body" />
		</xsl:call-template>
		<xsl:apply-templates select="Body | Appendix | Schedules" />
	</body>
	<xsl:if test="exists(ExplanatoryNotes | EarlierOrders | Include)">
		<conclusions>
			<xsl:apply-templates select="ExplanatoryNotes | EarlierOrders | Include" />
		</conclusions>
	</xsl:if>
	<xsl:if test="exists(*[not(self::SecondaryPrelims) and not(self::Body) and not(self::Appendix) and not(self::Schedules) and not(self::ExplanatoryNotes) and not(self::EarlierOrders) and not (self::Include)])">
		<xsl:message terminate="yes">
			<xsl:sequence select="*/local-name()" />
		</xsl:message>
	</xsl:if>
</xsl:template>

<xsl:template match="Body">
	<xsl:apply-templates>
		<xsl:with-param name="context" select="('Body')" tunnel="yes" />
	</xsl:apply-templates>
</xsl:template>


<!-- blocks -->

<xsl:template match="BlockText">
	<blockContainer ukl:Name="BlockText">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="Para | P1para | P2para | P3para | P4para | P5para | P6para | P7para">
	<xsl:call-template name="para-with-amendment" />
</xsl:template>

<xsl:template match="Text">
	<p>
		<xsl:apply-templates />
	</p>
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
	<def ukl:Name="Definition">
		<xsl:apply-templates />
	</def>
</xsl:template>

<xsl:template match="Span">
	<span>
		<xsl:apply-templates />
	</span>
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
			<xsl:if test="matches(., '^\s')">
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:value-of select="normalize-space(.)" />
			<xsl:if test="matches(., '\s$')">
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
