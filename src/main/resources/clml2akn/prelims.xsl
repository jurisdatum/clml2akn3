<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukm local">


<xsl:template match="PrimaryPrelims">
	<preface>
		<xsl:call-template name="add-internal-id-if-necessary" />
		<xsl:apply-templates select="Title | Number" />
		<xsl:choose>
			<xsl:when test="$doc-short-type = 'asp'">
				<xsl:apply-templates select="DateOfEnactment" />
				<xsl:apply-templates select="LongTitle" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="LongTitle | DateOfEnactment" />
			</xsl:otherwise>
		</xsl:choose>
	</preface>
	<xsl:apply-templates select="PrimaryPreamble" />
</xsl:template>

<xsl:template match="PrimaryPrelims/Title | SecondaryPrelims/Title">
	<block name="title">
		<shortTitle>
			<xsl:apply-templates />
		</shortTitle>
	</block>
</xsl:template>

<xsl:template match="PrimaryPrelims/Number | SecondaryPrelims/Number">
	<block name="number">
		<docNumber>
			<xsl:apply-templates />
		</docNumber>
	</block>
</xsl:template>

<xsl:template match="SecondaryPrelims">
	<preface>
		<xsl:call-template name="add-internal-id-if-necessary" />
		<xsl:call-template name="banner" />
		<xsl:apply-templates select="* except SecondaryPreamble" />
	</preface>
	<xsl:apply-templates select="SecondaryPreamble" />
</xsl:template>

<xsl:template match="LongTitle">
	<longTitle>
		<p>
			<xsl:apply-templates />
		</p>
	</longTitle>
</xsl:template>

<xsl:template match="DateOfEnactment">
	<block name="dateOfEnactment">
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


<xsl:template name="collapse-para">
	<xsl:choose>
		<xsl:when test="empty(preceding-sibling::*) and empty(following-sibling::*)">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:otherwise>
			<container name="para">
				<xsl:apply-templates />
			</container>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


<!-- secondary -->

<xsl:template name="banner">
	<xsl:choose>
		<xsl:when test="$doc-short-type = 'ssi'">
			<block name="banner">Scottish Statutory Instruments</block>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template match="Correction | Draft">
	<container name="{ lower-case(local-name()) }">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="Correction/Para | Draft/Para">
	<xsl:call-template name="collapse-para" />
</xsl:template>

<!-- <xsl:template match="Correction/Para/Text | Draft/Para/Text">
	<block name="{ lower-case(local-name(../..)) }">
		<xsl:apply-templates />
	</block>
</xsl:template> -->


<xsl:template match="SubjectInformation">
	<container name="subjects">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="Subject">
	<container name="subject">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="Subject/Title | Subject/Subtitle">
	<block name="{ lower-case(local-name()) }">
		<concept refersTo="#">
			<xsl:apply-templates />
		</concept>
	</block>
</xsl:template>

<xsl:template match="Approved">
	<block name="approved">
		<xsl:apply-templates />
	</block>
</xsl:template>

<xsl:function name="local:lower-camel-case" as="xs:string">
	<xsl:param name="s" as="xs:string" />
	<xsl:value-of select="concat(lower-case(substring($s, 1, 1)), substring($s, 2))" />
</xsl:function>

<xsl:template match="LaidDraft | SiftedDate | MadeDate | LaidDate | ComingIntoForce[not(ComingIntoForceClauses)] | ComingIntoForceClauses">
	<block name="{ local:lower-camel-case(local-name()) }">
		<xsl:apply-templates />
	</block>
</xsl:template>
<xsl:template match="ComingIntoForce[ComingIntoForceClauses]">
	<container name="{ local:lower-camel-case(local-name()) }">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="LaidDraft/Text | SiftedDate/Text | MadeDate/Text | LaidDate/Text | ComingIntoForce[not(ComingIntoForceClauses)]/Text | ComingIntoForceClauses/Text">
	<span>
		<xsl:apply-templates />
	</span>
</xsl:template>
<xsl:template match="ComingIntoForce[ComingIntoForceClauses]/Text">
	<p>
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="SiftedDate/DateText | MadeDate/DateText | LaidDate/DateText | ComingIntoForce/DateText | ComingIntoForceClauses/DateText">
	<docDate>
		<xsl:attribute name="date">
			<xsl:choose>
				<xsl:when test="parent::SiftedDate">
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:Sifted/@Date" />
				</xsl:when>
				<xsl:when test="parent::MadeDate">
					<xsl:variable name="ukm-made" as="element(ukm:Made)?" select="/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Made" />
					<xsl:choose>
						<xsl:when test="exists($ukm-made)">
							<xsl:value-of select="$ukm-made/@Date" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local:parse-date(.)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="parent::LaidDate">
					<xsl:variable name="from-text" as="xs:date?" select="local:parse-date(.)" />
					<xsl:choose>
						<xsl:when test="exists($from-text)">
							<xsl:value-of select="$from-text" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="pos" as="xs:integer" select="count(parent::*/preceding-sibling::LaidDate) + 1" />
							<xsl:value-of select="/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:Laid[$pos]/@Date" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="parent::ComingIntoForce">
					<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:ComingIntoForce/ukm:DateTime/@Date" />
				</xsl:when>
				<xsl:when test="parent::ComingIntoForceClauses">
					<xsl:variable name="from-text" as="xs:date?" select="local:parse-date(.)" />
					<xsl:choose>
						<xsl:when test="exists($from-text)">
							<xsl:value-of select="$from-text" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="pos" as="xs:integer" select="count(../preceding-sibling::ComingIntoForceClauses) + 1" />
							<xsl:value-of select="/Legislation/ukm:Metadata/ukm:SecondaryMetadata/ukm:ComingIntoForce/ukm:DateTime[$pos]/@Date" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
			</xsl:choose>
		</xsl:attribute>
		<xsl:apply-templates />
	</docDate>
</xsl:template>



<!-- preamble -->

<xsl:template match="PrimaryPreamble">
	<xsl:if test="exists(*[not(self::EnactingTextOmitted)]) or exists(EnactingTextOmitted/*)">
	<preamble>
		<xsl:apply-templates />
	</preamble>
	</xsl:if>
</xsl:template>

<xsl:template match="SecondaryPreamble">
	<preamble>
		<xsl:apply-templates />
	</preamble>
</xsl:template>

<xsl:template match="RoyalPresence">
	<container name="royalPresence">
		<xsl:apply-templates />
	</container>
</xsl:template>

<xsl:template match="RoyalPresence/Para">
	<xsl:call-template name="collapse-para" />
<!-- 	<xsl:choose>
		<xsl:when test="empty(preceding-sibling::*) and empty(following-sibling::*)">
			<xsl:apply-templates />
		</xsl:when>
		<xsl:otherwise>
			<container name="para">
				<xsl:apply-templates />
			</container>
		</xsl:otherwise>
	</xsl:choose> -->
</xsl:template>

<xsl:template match="IntroductoryText">
	<p>
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="IntroductoryText[P]">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="IntroductoryText/P[P3]">
	<blockContainer>
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="IntroductoryText/P/P3">
	<blockContainer class="P3">
		<xsl:apply-templates />
	</blockContainer>
</xsl:template>

<xsl:template match="EnactingText">
	<formula name="enactingText">
		<xsl:apply-templates />
	</formula>
</xsl:template>

<xsl:template match="EnactingTextOmitted">
</xsl:template>

<xsl:template match="Contents" />

</xsl:transform>
