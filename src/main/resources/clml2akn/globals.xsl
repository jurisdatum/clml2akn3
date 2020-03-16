<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:dc="http://purl.org/dc/elements/1.1/"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukm dc html local">


<!-- keys -->

<xsl:key name="id" match="*" use="@id" />

<xsl:key name="short-id" match="*" use="@shortId" />


<!-- functions -->

<xsl:function name="local:get-elements-by-id" as="element()*">
	<xsl:param name="id" as="xs:string" />
	<xsl:param name="top" as="node()" />
	<xsl:sequence select="(key('id', $id, $top), key('short-id', $id, $top))" />
</xsl:function>

<xsl:function name="local:get-elements-for-ref" as="element()*">
	<xsl:param name="ref" as="attribute()" />
	<xsl:variable name="id" as="xs:string" select="string($ref)" />
	<xsl:variable name="root" as="document-node()" select="root($ref)" />
	<xsl:sequence select="local:get-elements-by-id($id, $root)" />
</xsl:function>

<xsl:function name="local:get-element-for-ref" as="element()?">
	<xsl:param name="ref" as="attribute()" />
	<xsl:sequence select="local:get-elements-for-ref($ref)[1]" />
</xsl:function>

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
		<xsl:when test="$e/self::P/parent::Pblock or $e/self::P/parent::PsubBlock">
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
		<xsl:when test="$e/self::P and not($e/parent::Pblock) and not($e/parent::PsubBlock)">
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
			<xsl:value-of select="concat('term-', lower-case(translate(normalize-space($term), ' &#xA;&#34;“”%', '-')))" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:parse-date" as="xs:date?">
	<xsl:param name="text" as="xs:string" />
	<xsl:variable name="temp" as="xs:date*">
		<xsl:analyze-string regex="(\d{{1,2}})(st|nd|rd|th)?( day of)? (January|February|March|April|May|June|July|August|September|October|November|December) (\d{{4}})" select="normalize-space($text)">
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


<xsl:function name="local:p1group-collapses-into-p1" as="xs:boolean">
	<xsl:param name="p1-group" as="element(P1group)" />
	<xsl:sequence select="exists($p1-group/P1) and empty($p1-group/parent::*/P1group[count(P1) gt 1])" />
</xsl:function>


<xsl:function name="local:get-first-index-of-node" as="xs:integer?">
	<xsl:param name="n" as="node()" />
	<xsl:param name="nodes" as="node()*" />
	<xsl:variable name="index" as="xs:integer*">
		<xsl:for-each select="$nodes">
			<xsl:if test=". is $n">
				<xsl:value-of select="position()" />
			</xsl:if>
		</xsl:for-each>
	</xsl:variable>
	<xsl:value-of select="$index[1]" />
</xsl:function>


<!-- internal identifiers -->

<xsl:function name="local:get-internal-id" as="xs:string">
	<xsl:param name="e" as="element()?" />
	<xsl:choose>
		<xsl:when test="empty($e)">
			<xsl:sequence select="''" />
		</xsl:when>
		<xsl:when test="exists($e/ancestor::Version)">
			<xsl:variable name="version" as="element(Version)" select="$e/ancestor::Version" />
			<xsl:choose>
				<xsl:when test="exists($e/@id) and exists($version/@Description)">
					<xsl:sequence select="concat($e/@id, '-', lower-case($version/@Description))" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="generate-id($e)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="exists($e/ancestor::BlockAmendment) or exists($e/ancestor::html:td)"> <!-- guards against two elements having the same @id, e.g., asp/2003/6/2003-12-16 -->
			<xsl:sequence select="generate-id($e)" />
		</xsl:when>
		<xsl:when test="exists($e/@id)">
			<xsl:sequence select="$e/@id" />
		</xsl:when>
		<xsl:when test="$e/self::PrimaryPrelims or $e/self::SecondaryPrelims or $e/self::EUPrelims">
			<xsl:sequence select="'preface'" />
		</xsl:when>
		<xsl:when test="$e/self::Body or $e/self::EUBody">
			<xsl:sequence select="'body'" />
		</xsl:when>
		<xsl:when test="$e/self::SignedSection">
			<xsl:choose>
				<xsl:when test="$e/parent::Body/parent::*/parent::Legislation">
					<xsl:sequence select="'signatures'" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="concat(local:get-internal-id($e/parent::*), '-signatures')" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$e/self::Schedules">
			<xsl:sequence select="'schedules'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="generate-id($e)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<!-- use this function only for creating internal references, not for populating eId attributes -->
<xsl:function name="local:get-internal-id-for-ref" as="xs:string">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$e/self::P1group and local:p1group-collapses-into-p1($e)">
			<xsl:value-of select="local:get-internal-id($e/P1)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="local:get-internal-id($e)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:key name="internal-links" match="InternalLink" use="@Ref" />

<xsl:template name="add-internal-id">
	<xsl:param name="from" as="element()" select="." />
	<xsl:variable name="is-in-main-body" as="xs:boolean" select="empty($from/ancestor::BlockAmendment) and empty($from/ancestor::BlockExtract) and empty($from/ancestor::html:td)" />
	<xsl:variable name="is-necessary-for-metadata" as="xs:boolean" select="exists($from/@RestrictExtent) or exists($from/@RestrictStartDate) or exists($from/@RestrictEndDate) or exists($from/@Status) or exists(@ConfersPower) or exists(@Match)" />
	<xsl:variable name="is-necessary-for-reference" as="xs:boolean">
		<xsl:variable name="from" as="element()" select="if ($from/self::P1 and empty($from/@id) and exists($from/parent::P1group/@id)) then $from/parent::* else $from" />
		<xsl:sequence select="exists($from/@id) and exists(key('internal-links', $from/@id, root($from)))" />
	</xsl:variable>
	<xsl:if test="($is-in-main-body and exists($from/@id)) or $is-necessary-for-metadata or $is-necessary-for-reference">
		<xsl:attribute name="eId">
			<xsl:value-of select="local:get-internal-id($from)" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:template name="add-internal-id-if-necessary">
	<xsl:param name="from" as="element()" select="." />
	<xsl:variable name="is-necessary-for-metadata" as="xs:boolean" select="exists($from/@RestrictExtent) or exists($from/@RestrictStartDate) or exists($from/@RestrictEndDate) or exists($from/@Status) or exists(@ConfersPower) or exists(@Match)" />
	<xsl:variable name="is-necessary-for-reference" as="xs:boolean" select="exists($from/@id) and exists(key('internal-links', $from/@id, root($from)))" />
	<xsl:if test="$is-necessary-for-metadata or $is-necessary-for-reference">
		<xsl:attribute name="eId">
			<xsl:value-of select="local:get-internal-id($from)" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>


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

<xsl:variable name="doc-minor-type" as="xs:string?" select="/Legislation/ukm:Metadata/ukm:*/ukm:DocumentClassification/ukm:DocumentMinorType/@Value" />

<xsl:variable name="doc-year" as="xs:integer?">
	<xsl:variable name="ukm-year" as="element(ukm:Year)?" select="/Legislation/ukm:Metadata/(ukm:PrimaryMetadata | ukm:SecondaryMetadata | ukm:EUMetadata)/ukm:Year" />
	<xsl:choose>
		<xsl:when test="exists($ukm-year)">
			<xsl:value-of select="xs:integer($ukm-year/@Value)" />
		</xsl:when>
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

<xsl:variable name="doc-version" as="xs:string">
	<xsl:variable name="dc-identifier" as="xs:string" select="(//dc:identifier)[1]" />
	<xsl:value-of select="substring-after($dc-identifier, concat($doc-short-id, '/'))" />
</xsl:variable>

</xsl:transform>
