<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukm dc local">


<!-- keys -->

<xsl:key name="id" match="*" use="@id" />


<!-- functions -->

<xsl:variable name="short-types" as="element()">
	<shortTypes
		UnitedKingdomPublicGeneralAct = "ukpga"
		UnitedKingdomLocalAct = "ukla"
		ScottishAct = "asp"
		WelshNationalAssemblyAct = "anaw"
		WelshAssemblyMeasure = "mwa"
		UnitedKingdomChurchMeasure = "ukcm"
		NorthernIrelandAct = "nia"
		ScottishOldAct = "aosp"
		EnglandAct = "aep"
		IrelandAct = "aip"
		GreatBritainAct = "apgb"
		NorthernIrelandAssemblyMeasure = "mnia"
		NorthernIrelandParliamentAct = "apni"
		UnitedKingdomStatutoryInstrument = "uksi"
		WelshStatutoryInstrument = "wsi"
		ScottishStatutoryInstrument = "ssi"
		NorthernIrelandOrderInCouncil = "nisi"
		NorthernIrelandStatutoryRule = "nisr"
		UnitedKingdomChurchInstrument = "ukci"
		UnitedKingdomMinisterialDirection = "ukmd"
		UnitedKingdomMinisterialOrder = "ukmo"
		UnitedKingdomStatutoryRuleOrOrder = "uksro"
		NorthernIrelandStatutoryRuleOrOrder = "nisro"
		UnitedKingdomDraftPublicBill = "ukdpb"
		UnitedKingdomDraftStatutoryInstrument = "ukdsi"
		ScottishDraftStatutoryInstrument = "sdsi"
		NorthernIrelandDraftStatutoryRule = "nidsr"
		EuropeanUnionRegulation = "eur"
		EuropeanUnionDecision = "eudn"
		EuropeanUnionDirective = "eudr"
		EuropeanUnionTreaty = "eut"
	/>
</xsl:variable>

<xsl:function name="local:short-type-from-long" as="xs:string">
	<xsl:param name="long-type" as="xs:string" />
	<xsl:value-of select="$short-types/@*[name() = $long-type]" />
</xsl:function>

<xsl:function name="local:element-is-structural" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="name" select="local-name($e)" />
	<xsl:choose>
		<xsl:when test="$name = ('Group', 'Part', 'Chapter', 'Pblock', 'PsubBlock')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('P1group', 'P2group', 'P3group')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('P1', 'P2', 'P3', 'P4', 'P5', 'P6', 'P7')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$e/self::UnorderedList[@Class='Definition']">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:element-is-para" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:variable name="name" select="local-name($e)" />
	<xsl:choose>
		<xsl:when test="$name = ('Para', 'P1para', 'P2para', 'P3para', 'P4para', 'P5para', 'P6para', 'P7para')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$name = ('P')">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="false()" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- returns an id for each term, to allow term elements to refer to metadata counterparts -->
<xsl:function name="local:make-term-id" as="xs:string">
	<xsl:param name="term" as="element(Term)" />
	<xsl:choose>
		<xsl:when test="$term/@id">
			<xsl:value-of select="$term/@id" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat('term-', lower-case(translate($term, ' &#xA;&#34;“”%', '-')))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:parse-date" as="xs:date?">
	<xsl:param name="text" as="xs:string" />
	<xsl:variable name="temp" as="xs:date*">
		<xsl:analyze-string regex="(\d{{1,2}})(st|nd|th)?( day of)? (January|February|March|April|May|June|July|August|September|October|November|December) (\d{{4}})" select="normalize-space($text)">
			<xsl:matching-substring>
				<xsl:variable name="day" as="xs:string" select="format-number(number(regex-group(1)), '00')" />
				<xsl:variable name="months" as="xs:string*" select="('January','February','March','April','May','June','July','August','September','October','November','December')" />
				<xsl:variable name="month" as="xs:string" select="format-number(index-of($months, regex-group(4)), '00')" />
				<xsl:variable name="year" as="xs:string" select="regex-group(5)" />
				<xsl:value-of select="concat($year, '-', $month, '-', $day)" />
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:variable>
	<xsl:sequence select="$temp[last()]" />
</xsl:function>


<!-- variables -->

<xsl:variable name="doc-long-type" as="xs:string">
	<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentMainType/@Value" />
</xsl:variable>

<xsl:variable name="doc-short-type" as="xs:string">
	<xsl:value-of select="local:short-type-from-long($doc-long-type)" />
</xsl:variable>

<xsl:variable name="doc-category" as="xs:string">
	<xsl:value-of select="/Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
</xsl:variable>

<xsl:variable name="doc-subtype" as="xs:string" select="''" />

<xsl:variable name="doc-year" as="xs:integer">
	<xsl:choose>
		<xsl:when test="exists(/Legislation/ukm:Metadata/ukm:*/ukm:Year)">
			<xsl:value-of select="xs:integer(/Legislation/ukm:Metadata/ukm:*/ukm:Year/@Value)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="xs:integer(/Legislation/ukm:Metadata/ukm:*/ukm:Year/@Value)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:variable>

<xsl:variable name="doc-number" as="xs:string" select="/Legislation/ukm:Metadata/ukm:*/ukm:Number/@Value" />

<xsl:variable name="doc-title" as="xs:string" select="/Legislation/ukm:Metadata/dc:title" />

<xsl:variable name="doc-short-id" as="xs:string">
	<xsl:value-of select="concat($doc-short-type, '/', $doc-year, '/', $doc-number)" />
</xsl:variable>

<xsl:variable name="doc-long-id" as="xs:string">
	<xsl:value-of select="concat('http://www.legislation.gov.uk/id/', $doc-short-id)" />
</xsl:variable>

</xsl:transform>
