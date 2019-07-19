<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:dct="http://purl.org/dc/terms/"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl local">

<xsl:template match="Metadata">
	<meta>
		<xsl:call-template name="identification" />
		<xsl:call-template name="references" />
		<xsl:call-template name="notes" />
		<xsl:call-template name="proprietary" />
	</meta>
</xsl:template>

<xsl:variable name="work-date" as="xs:string">
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/PrimaryMetadata/EnactmentDate)">
					<xsl:value-of select="/ukl:Legislation/Metadata/PrimaryMetadata/EnactmentDate/@Date" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="prelim-date" as="xs:date?" select="local:parse-date(/ukl:Legislation/ukl:Primary/ukl:PrimaryPrelims/ukl:DateOfEnactment/ukl:DateText)" />
					<xsl:choose>
						<xsl:when test="exists($prelim-date)">
							<xsl:value-of select="$prelim-date" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(/ukl:Legislation/Metadata/PrimaryMetadata/Year/@Value, '-01-01')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/Made)">
					<xsl:value-of select="/ukl:Legislation/Metadata/SecondaryMetadata/Made/@Date" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="prelim-date" as="xs:date?" select="local:parse-date(/ukl:Legislation/ukl:Secondary/ukl:SecondaryPrelims/ukl:MadeDate/ukl:DateText)" />
					<xsl:choose>
						<xsl:when test="exists($prelim-date)">
							<xsl:value-of select="$prelim-date" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="concat(/ukl:Legislation/Metadata/SecondaryMetadata/Year/@Value, '-01-01')" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:value-of select="/ukl:Legislation/Metadata/EUMetadata/EnactmentDate/@Date" />
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-date-name" as="xs:string">
	<xsl:choose>
		<xsl:when test="$doc-category = 'primary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/PrimaryMetadata/EnactmentDate)">
					<xsl:text>enacted</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="prelim-date" as="xs:date?" select="local:parse-date(/ukl:Legislation/ukl:Primary/ukl:PrimaryPrelims/ukl:DateOfEnactment/ukl:DateText)" />
					<xsl:choose>
						<xsl:when test="exists($prelim-date)">
							<xsl:text>enacted</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>estimated</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'secondary'">
			<xsl:choose>
				<xsl:when test="exists(/ukl:Legislation/Metadata/SecondaryMetadata/Made)">
					<xsl:text>made</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="prelim-date" as="xs:date?" select="local:parse-date(/ukl:Legislation/ukl:Secondary/ukl:SecondaryPrelims/ukl:MadeDate/ukl:DateText)" />
					<xsl:choose>
						<xsl:when test="exists($prelim-date)">
							<xsl:text>made</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>estimated</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:text>adopted</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-author" as="xs:string">
	<xsl:choose>
		<xsl:when test="starts-with($doc-long-type, 'EuropeanUnion')">
			<xsl:value-of select="EUMetadata/CreatedBy[1]/@URI" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="temp" as="xs:string">
				<xsl:choose>
					<xsl:when test="$doc-long-type = 'EnglandAct'">
						<xsl:text>legislature/EnglishParliament</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'GreatBritainAct'">
						<xsl:text>legislature/ParliamentOfGreatBritain</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'IrelandAct'">
						<xsl:text>legislature/OldIrishParliament</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandAct'">
						<xsl:text>legislature/NorthernIrelandAssembly</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandAssemblyMeasure'">
						<xsl:text>legislature/NorthernIrelandAssembly</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandParliamentAct'">
						<xsl:text>legislature/NorthernIrelandParliament</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandOrderInCouncil'">
						<xsl:text>government/uk</xsl:text>
					</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandDraftOrderInCouncil'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRule'">government/northern-ireland</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandDraftStatutoryRule'">government/northern-ireland</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishAct'">legislature/ScottishParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishOldAct'">legislature/OldScottishParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishStatutoryInstrument'">government/scotland</xsl:when>
					<xsl:when test="$doc-long-type = 'ScottishDraftStatutoryInstrument'">government/scotland</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomChurchInstrument'">legislature/GeneralSynod</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomChurchMeasure'">legislature/GeneralSynod</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomPrivateAct'">legislature/UnitedKingdomParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomPublicGeneralAct'">legislature/UnitedKingdomParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomLocalAct'">legislature/UnitedKingdomParliament</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialOrder'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryInstrument'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomDraftStatutoryInstrument'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshAssemblyMeasure'">legislature/NationalAssemblyForWales</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshNationalAssemblyAct'">legislature/NationalAssemblyForWales</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshStatutoryInstrument'">government/wales</xsl:when>
					<xsl:when test="$doc-long-type = 'WelshDraftStatutoryInstrument'">government/wales</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialDirection'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryRuleOrOrder'">government/uk</xsl:when>
					<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRuleOrOrder'">government/northern-ireland</xsl:when>
				</xsl:choose>
			</xsl:variable>
			<xsl:value-of select="concat('http://www.legislation.gov.uk/id/', $temp)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-country" as="xs:string">
	<xsl:choose>
		<xsl:when test="$doc-long-type = 'EnglandAct'">
			<xsl:text>GB-ENG</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'GreatBritainAct'">
			<xsl:text>GB-GBN</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'IrelandAct'">
			<xsl:text>IE</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = ('NorthernIrelandAct', 'NorthernIrelandAssemblyMeasure', 'NorthernIrelandParliamentAct', 'NorthernIrelandOrderInCouncil', 'NorthernIrelandDraftOrderInCouncil', 'NorthernIrelandStatutoryRule', 'NorthernIrelandDraftStatutoryRule', 'NorthernIrelandStatutoryRuleOrOrder')">
			<xsl:text>GB-NIR</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = ('ScottishAct', 'ScottishOldAct', 'ScottishStatutoryInstrument', 'ScottishDraftStatutoryInstrument')">
			<xsl:text>GB-SCT</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-long-type = ('WelshAssemblyMeasure', 'WelshNationalAssemblyAct', 'WelshStatutoryInstrument', 'WelshDraftStatutoryInstrument')">
			<xsl:text>GB-WLS</xsl:text>
		</xsl:when>
		<xsl:when test="starts-with($doc-long-type, 'EuropeanUnion')">
			<xsl:text>EU</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<text>GB-UKM</text>
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="work-cite" as="xs:string">
	<xsl:choose>
		<xsl:when test="$doc-long-type = 'EnglandAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'GreatBritainAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'IrelandAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' [I]')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' (N.I.)')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandAssemblyMeasure'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' (N.I.)')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandParliamentAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' (N.I.)')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandOrderInCouncil' or $doc-long-type = 'NorthernIrelandDraftOrderInCouncil'">
			<xsl:variable name="alt-num" select="SecondaryMetadata/AlternativeNumber[@Category='NI']/@Value" />
			<xsl:value-of select="concat('S.I. ', $doc-year, '/', $doc-number, ' (N.I. ', $alt-num, ')')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRule' or $doc-long-type = 'NorthernIrelandDraftStatutoryRule'">
			<xsl:choose>
				<xsl:when test="SecondaryMetadata/AlternativeNumber[@Category='C']">
					<xsl:variable name="c-num" select="SecondaryMetadata/AlternativeNumber[@Category='C']/@Value" />
					<xsl:value-of select="concat('S.R. ', $doc-year, '/', $doc-number, ' (C. ', $c-num, ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.R. ', $doc-year, '/', $doc-number)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'NorthernIrelandStatutoryRuleOrOrder'">
			<xsl:choose>
				<xsl:when test="SecondaryMetadata/AlternativeNumber[@Category='C']">
					<xsl:variable name="c-num" select="SecondaryMetadata/AlternativeNumber[@Category='C']/@Value" />
					<xsl:value-of select="concat('S.R. &amp; O. (N.I.) ', $doc-year, '/', $doc-number, ' (C. ', $c-num, ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.R. &amp; O. (N.I.) ', $doc-year, '/', $doc-number)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'ScottishAct'">
			<xsl:value-of select="concat($doc-year, ' asp ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'ScottishOldAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number, ' [S]')" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'ScottishStatutoryInstrument' or $doc-long-type = 'ScottishDraftStatutoryInstrument'">
			<xsl:choose>
				<xsl:when test="SecondaryMetadata/AlternativeNumber[@Category='C']">
					<xsl:variable name="c-num" select="SecondaryMetadata/AlternativeNumber[@Category='C']/@Value" />
					<xsl:value-of select="concat('S.S.I. ', $doc-year, '/', $doc-number, ' (C. ', $c-num, ')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.S.I. ', $doc-year, '/', $doc-number)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomChurchInstrument'">
			<xsl:value-of select="concat('Church Instrument ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomChurchMeasure'">
			<xsl:value-of select="concat($doc-year, ' No. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomPrivateAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomPublicGeneralAct'">
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomLocalAct'">
			<xsl:variable name="number">
				<xsl:number value="$doc-number" format="i" />
			</xsl:variable>
			<xsl:value-of select="concat($doc-year, ' c. ', $number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialOrder'">
			<xsl:value-of select="concat('Ministerial Order ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomMinisterialDirection'">
			<xsl:value-of select="concat('Ministerial Direction ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryInstrument' or $doc-long-type = 'UnitedKingdomDraftStatutoryInstrument'">
			<xsl:value-of select="concat('S.I. ', $doc-year, '/', $doc-number)" />
			<xsl:for-each select="SecondaryMetadata/AlternativeNumber[@Category='C' or @Category='L' or @Category='S']">
				<xsl:value-of select="concat(' (', @Category,'. ', @Value, ')')" />
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'UnitedKingdomStatutoryRuleOrOrder'">
			<xsl:value-of select="concat('S.R. &amp; O. ', $doc-year, '/', $doc-number)" />
			<xsl:for-each select="SecondaryMetadata/AlternativeNumber[@Category='C' or @Category='L' or @Category='S']">
				<xsl:value-of select="concat(' (', @Category,'. ', @Value, ')')" />
			</xsl:for-each>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'WelshAssemblyMeasure'">
			<xsl:value-of select="concat($doc-year, ' nawm ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'WelshNationalAssemblyAct'">
			<xsl:value-of select="concat($doc-year, ' anaw ', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'WelshStatutoryInstrument' or $doc-long-type = 'WelshDraftStatutoryInstrument'">
			<xsl:variable name="alt-num" select="SecondaryMetadata/AlternativeNumber[@Category='W' or @Category='Cy']/@Value" />
			<xsl:choose>
				<xsl:when test="SecondaryMetadata/AlternativeNumber[@Category='C']">
					<xsl:variable name="c-num" select="SecondaryMetadata/AlternativeNumber[@Category='C']/@Value" />
					<xsl:value-of select="concat('S.I. ', $doc-year, '/', $doc-number, ' (W. ', $alt-num, ') (C. ', $c-num,')')" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat('S.I. ', $doc-year, '/', $doc-number, ' (W. ', $alt-num, ')')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$doc-long-type = 'EuropeanUnionRegulation'">
			<xsl:value-of select="concat('Regulation (EU) ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'EuropeanUnionDecision'">
			<xsl:value-of select="concat('Decision (EU) ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:when test="$doc-long-type = 'EuropeanUnionDirective'">
			<xsl:value-of select="concat('Directive (EU) ', $doc-year, '/', $doc-number)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat($doc-year, ' c. ', $doc-number)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="expr-date" as="xs:string">
	<xsl:variable name="dct-valid" as="element()?" select="/ukl:Legislation/Metadata/dct:valid" />
	<xsl:choose>
		<xsl:when test="exists($dct-valid)">
			<xsl:value-of select="$dct-valid" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$work-date" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="expr-date-name" as="xs:string">
	<xsl:variable name="dct-valid" as="element()?" select="/ukl:Legislation/Metadata/dct:valid" />
	<xsl:choose>
		<xsl:when test="exists($dct-valid)">
			<xsl:text>validFrom</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$work-date-name" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="lang" as="xs:string" select="if (/ukl:Legislation/Metadata/dc:language = 'cy') then 'cym' else 'eng'" />


<xsl:template name="identification">
	<identification source="#source">
		<FRBRWork>
			<FRBRthis value="{ $doc-long-id }" />
			<FRBRuri value="{ $doc-long-id }" />
			<FRBRdate date="{ $work-date }" name="{ $work-date-name }" />
			<FRBRauthor href="{ $work-author }" />
			<FRBRcountry value="{ $work-country }" />
			<FRBRnumber value="{ $doc-number }" />
			<FRBRname value="{ $work-cite }" />
			<FRBRprescriptive value="true" />
		</FRBRWork>
		<FRBRExpression>
			<FRBRthis value="http://www.legislation.gov.uk/{ $doc-short-id }" />
			<FRBRuri value="http://www.legislation.gov.uk/{ $doc-short-id }" />
			<FRBRdate date="{ $expr-date }" name="{ $expr-date-name }" />
			<FRBRauthor href="#source" />
			<FRBRlanguage language="{ $lang }" />
		</FRBRExpression>
		<FRBRManifestation>
			<FRBRthis value="http://www.legislation.gov.uk/{ $doc-short-id }/data.akn" />
			<FRBRuri value="http://www.legislation.gov.uk/{ $doc-short-id }/data.akn" />
			<FRBRdate date="{ current-date() }" name="transform" />
			<FRBRauthor href="http://www.legislation.gov.uk" />
			<FRBRformat value="application/akn+xml" />
		</FRBRManifestation>
	</identification>
</xsl:template>

<xsl:template name="references">
	<references source="#source">
		<TLCOrganization eId="source" href="" showAs="" />
<!-- 	    <TLCConcept eId="varActYear" showAs="{ $doc-year }" href="" />
	    <TLCConcept eId="varActNo" showAs="{ $doc-number }" href="" />
	    <TLCConcept eId="varActTitle" showAs="{ $doc-title }" href="" /> -->
		<xsl:for-each-group select="//ukl:Term" group-by="local:make-term-id(.)">
			<TLCTerm eId="{ local:make-term-id(.) }" showAs="{.}" href="" />
		</xsl:for-each-group>
	</references>
</xsl:template>

<xsl:template name="notes">
	<xsl:if test="/ukl:Legislation/ukl:Commentaries/ukl:Commentary">
		<notes source="#source">
			<xsl:apply-templates select="/ukl:Legislation/ukl:Commentaries/ukl:Commentary" />
		</notes>
	</xsl:if>
</xsl:template>

<xsl:template name="proprietary">
	<proprietary source="#source">
		<xsl:apply-templates select="/ukl:Legislation/Metadata/*/Year" />
		<xsl:apply-templates select="dc:* | dct:*" />
	</proprietary>
</xsl:template>

<xsl:template match="ukm:*">
	<xsl:element name="ukm:{ local-name() }">
		<xsl:copy-of select="@*" />
	</xsl:element>
</xsl:template>

<xsl:template match="dc:*">
	<xsl:element name="dc:{ local-name() }">
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="dct:*">
	<xsl:element name="dct:{ local-name() }">
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

</xsl:transform>
