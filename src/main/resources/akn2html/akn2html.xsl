<?xml version="1.0" encoding="utf-8"?>

<!-- v3, written by Jim Mangiafico -->

<xsl:stylesheet version="2.0"
	xpath-default-namespace="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:math="http://www.w3.org/1998/Math/MathML"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukm="http://www.legislation.gov.uk/namespaces/metadata"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:local="http://jurisdatum.com/tna/akn2html"
	exclude-result-prefixes="xs math ukl ukm uk html fo local">

<xsl:param name="css-path" select="'/'" />

<xsl:output method="html" version="5" include-content-type="no" encoding="utf-8" indent="yes" />

<xsl:strip-space elements="*" />

<xsl:key name="id" match="*" use="@eId" />
<xsl:key name="note" match="note" use="@eId" />
<xsl:key name="note-ref" match="noteRef" use="substring(@href, 2)" />

<xsl:variable name="doc-short-type" as="xs:string" select="/akomaNtoso/*/@name" />

<xsl:variable name="doc-category" as="xs:string?">
	<xsl:variable name="primary-short-types" as="xs:string+" select="( 'ukpga', 'ukla', 'asp', 'anaw', 'mwa', 'ukcm', 'nia', 'aosp', 'aep', 'aip', 'apgb', 'mnia', 'apni' )" />
	<xsl:variable name="secondary-short-types" as="xs:string+" select="( 'uksi', 'wsi', 'ssi', 'nisi', 'nisr', 'ukci', 'ukmd', 'ukmo', 'uksro', 'nisro', 'ukdpb', 'ukdsi', 'sdsi', 'nidsr' )" />
	<xsl:variable name="eu-short-types" as="xs:string+" select="( 'eur', 'eudn', 'eudr', 'eut' )" />
	<xsl:choose>
		<xsl:when test="$doc-short-type = $primary-short-types">
			<xsl:text>primary</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-short-type = $secondary-short-types">
			<xsl:text>secondary</xsl:text>
		</xsl:when>
		<xsl:when test="$doc-short-type = $eu-short-types">
			<xsl:text>euretained</xsl:text>
		</xsl:when>
	</xsl:choose>
</xsl:variable>

<xsl:template name="add-class-attribute">
	<xsl:param name="classes" as="xs:string*" select="()" />
	<xsl:variable name="classes" as="xs:string*">
		<xsl:sequence select="$classes" />
		<xsl:if test="not(self::p)">
			<xsl:sequence select="local-name()" />
		</xsl:if>
		<xsl:sequence select="@name" />
		<xsl:sequence select="@uk:name" />
		<xsl:sequence select="@class" />
	</xsl:variable>
	<xsl:if test="exists($classes)">
		<xsl:attribute name="class">
			<xsl:value-of select="string-join($classes, ' ')" />
		</xsl:attribute>
	</xsl:if>
</xsl:template>

<xsl:key name="extent-restrictions" match="restriction[starts-with(@refersTo, '#extent-')]" use="substring(@href, 2)" />

<xsl:template name="add-extent-attribute">
	<xsl:if test="exists(self::act) or exists(@eId)">
		<xsl:variable name="id" as="xs:string?" select="@eId" />
		<xsl:variable name="restriction" as="element()?" select="key('extent-restrictions', $id)" />
		<xsl:if test="exists($restriction)">
			<xsl:variable name="extent" as="element(TLCLocation)" select="key('id', substring($restriction/@refersTo, 2))" />
			<xsl:attribute name="data-x-extent">
				<xsl:value-of select="$extent/@showAs" />
			</xsl:attribute>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:key name="temporal-restrictions" match="restriction[starts-with(@refersTo, '#period-')]" use="substring(@href, 2)" />

<xsl:template name="add-restrict-date-attributes">
	<xsl:if test="exists(self::act) or exists(@eId)">
		<xsl:variable name="id" as="xs:string?" select="@eId" />
		<xsl:variable name="restriction" as="element()?" select="key('temporal-restrictions', $id)" />
		<xsl:if test="exists($restriction)">
			<xsl:variable name="group" as="element(temporalGroup)" select="key('id', substring($restriction/@refersTo, 2))" />
			<xsl:variable name="interval" as="element(timeInterval)" select="$group/*" />
			<xsl:if test="exists($interval/@start)">
				<xsl:variable name="event" as="element(eventRef)" select="key('id', substring($interval/@start, 2))" />
				<xsl:attribute name="data-x-restrict-start-date">
					<xsl:value-of select="$event/@date" />
				</xsl:attribute>
			</xsl:if>
			<xsl:if test="exists($interval/@end)">
				<xsl:variable name="event" as="element(eventRef)" select="key('id', substring($interval/@end, 2))" />
				<xsl:attribute name="data-x-restrict-end-date">
					<xsl:value-of select="$event/@date" />
				</xsl:attribute>
			</xsl:if>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template name="add-restrict-attributes">
	<xsl:call-template name="add-extent-attribute" />
	<xsl:call-template name="add-restrict-date-attributes" />
</xsl:template>

<xsl:template name="add-status-attribute">
</xsl:template>

<xsl:key name="confers-power" match="uk:confersPower" use="substring(@href, 2)" />

<xsl:template name="add-confers-power-attribute">
	<xsl:if test="exists(self::act) or exists(@eId)">
		<xsl:variable name="id" as="xs:string?" select="@eId" />
		<xsl:variable name="restriction" as="element(uk:confersPower)?" select="key('confers-power', $id)" />
		<xsl:if test="exists($restriction)">
			<xsl:attribute name="data-x-confers-power">
				<xsl:text>true</xsl:text>
			</xsl:attribute>
		</xsl:if>
	</xsl:if>
</xsl:template>

<xsl:template name="add-status-attributes">
	<xsl:call-template name="add-status-attribute" />
	<xsl:call-template name="add-confers-power-attribute" />
</xsl:template>

<xsl:template name="add-extra-attributes">
	<xsl:call-template name="add-restrict-attributes" />
	<xsl:call-template name="add-status-attributes" />
</xsl:template>

<xsl:template name="attrs">
	<xsl:param name="classes" as="xs:string*" select="()" />
	<xsl:call-template name="add-class-attribute">
		<xsl:with-param name="classes" select="$classes" />
	</xsl:call-template>
	<xsl:apply-templates select="@* except (@name, @uk:name, @class)" />
	<xsl:call-template name="add-extra-attributes" />
</xsl:template>

<xsl:function name="local:is-big-level" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:value-of select="local-name($e) = ('title', 'part', 'chapter', 'section', 'subsection') or $e/self::hcontainer/@name = 'schedule'" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$e[self::group] or $e[self::part] or $e[self::chapter] or $e[self::hcontainer][@name='crossheading'] or
				$e[self::hcontainer][@name='P1group'] or $e[self::hcontainer][@name='schedule']" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:is-p1" as="xs:boolean">
	<xsl:param name="e" as="element()" />
	<xsl:choose>
		<xsl:when test="$doc-category = 'euretained'">
			<xsl:value-of select="exists($e[self::article] | $e[self::paragraph][ancestor::hcontainer[@name='schedule']][not(ancestor::paragraph)])" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="exists($e[self::section] | $e[self::article] | $e[self::hcontainer][@name='regulation'] |
				$e[self::rule] | $e[self::paragraph][ancestor::hcontainer[@name='schedule']][not(ancestor::paragraph)])" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="/akomaNtoso">
	<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;
</xsl:text>
	<html>
		<head>
			<meta charset="utf-8" />
			<title>
				<xsl:choose>
					<xsl:when test="//shortTitle">
						<xsl:value-of select="//shortTitle[1]" />
					</xsl:when>
					<xsl:when test="//docTitle">
						<xsl:value-of select="//docTitle[1]" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="//FRBRWork/FRBRthis/@value" />
					</xsl:otherwise>
				</xsl:choose>
			</title>
			<xsl:choose>
				<xsl:when test="$doc-short-type = 'nia'">
					<link rel="stylesheet" href="{$css-path}nia.css" type="text/css" />
				</xsl:when>
				<xsl:when test="$doc-category = 'secondary'">
					<link rel="stylesheet" href="{$css-path}secondary.css" type="text/css" />
				</xsl:when>
				<xsl:when test="$doc-category = 'euretained'">
					<link rel="stylesheet" href="{$css-path}euretained.css" type="text/css" />
				</xsl:when>
				<xsl:otherwise>
					<link rel="stylesheet" href="{$css-path}primary.css" type="text/css" />
				</xsl:otherwise>
			</xsl:choose>
		</head>
		<body>
			<xsl:apply-templates />
			<xsl:call-template name="footnotes" />
		</body>
	</html>
</xsl:template>


<!-- document types -->

<xsl:template match="act">
	<article>
		<xsl:attribute name="class">
			<xsl:value-of select="local-name()" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="$doc-category" />
			<xsl:text> </xsl:text>
			<xsl:value-of select="@name" />
		</xsl:attribute>
		<xsl:call-template name="add-restrict-attributes" />
		<xsl:apply-templates />
	</article>
</xsl:template>


<!-- metadata -->

<xsl:template match="meta">
	<div class="meta" vocab="{namespace-uri()}/" style="display:none">
		<xsl:apply-templates select="identification" />
	</div>
</xsl:template>

<xsl:template match="meta/*">
	<div resource="#{name()}" typeof="{name()}">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="identification/*">
	<div resource="#{name()}" property="{name()}" typeof="{name()}">
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="meta/*//*[not(parent::identification)][not(ancestor-or-self::note)]">
	<xsl:choose>
		<xsl:when test="text()[normalize-space()]">
			<div property="{name()}"><xsl:value-of select="." /></div>
		</xsl:when>
		<xsl:otherwise>
			<div>
				<xsl:if test="not(parent::meta) and ((namespace-uri() = namespace-uri(..)) or parent::proprietary)">
					<xsl:attribute name="property"><xsl:value-of select="name()" /></xsl:attribute>
				</xsl:if>
				<xsl:attribute name="typeof"><xsl:value-of select="name()" /></xsl:attribute>
				<xsl:variable name="prefix" select="prefix-from-QName(resolve-QName(name(), .))" as="xs:string?" />
				<xsl:for-each select="@*">
					<meta>
						<xsl:attribute name="property">
							<xsl:if test="$prefix">
								<xsl:value-of select="$prefix" /><xsl:text>:</xsl:text>
							</xsl:if>
							<xsl:value-of select="name()" />
						</xsl:attribute>
						<xsl:attribute name="content">
							<xsl:value-of select="translate(., '&#128;&#132;&#149;&#150;&#153;&#157;', '')" />
						</xsl:attribute>
					</meta>
				</xsl:for-each>
				<xsl:apply-templates select="*" />
			</div>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="note">
	<xsl:param name="marker" />
	<div>
		<xsl:call-template name="attrs" />
		<xsl:if test="$marker != ''">
			<span class="marker">
				<xsl:value-of select="$marker"/>
			</span>
		</xsl:if>
		<xsl:apply-templates />
	</div>
</xsl:template>

<!-- sequence of unique noteRefs, uniqueness determined by reference to the same note -->
<xsl:variable name="note-refs" as="element()*">
	<xsl:for-each-group select="//noteRef[not(@placement='inline')]" group-by="@href">
		<xsl:variable name="id" as="xs:string" select="substring(@href, 2)" />
		<xsl:variable name="note" as="element()?" select="key('id', $id)" />
		<!-- need to exclude noteRefs to elements that are not in the metadata section, they'll appear in the document in due course -->
		<xsl:if test="exists($note) and $note/ancestor::notes">
			<xsl:sequence select="current-group()[1]" /><!-- select="."? -->
		</xsl:if>
	</xsl:for-each-group>
</xsl:variable>

<xsl:template name="display-note">
	<xsl:variable name="id" select="substring(@href, 2)" as="xs:string" />
	<xsl:variable name="note" select="key('note', $id)" as="element()?" />
	<xsl:apply-templates select="$note">
		<xsl:with-param name="marker" select="@marker" />
	</xsl:apply-templates>
</xsl:template>

<xsl:template name="display-notes">
	<xsl:param name="note-refs" as="element()*" />
	<xsl:param name="heading" as="xs:string" />
	<xsl:if test="exists($note-refs)">
		<div class="{tokenize($note-refs[1]/@class, ' ')[last()]}">
			<div><xsl:value-of select="$heading" /></div>
			<xsl:for-each select="$note-refs">
				<xsl:call-template name="display-note" />
			</xsl:for-each>
		</div>
	</xsl:if>
</xsl:template>

<xsl:template name="annotations">
	<xsl:param name="root" as="element()+" select="." />
	<xsl:param name="wrapper-element-name" select="'footer'" as="xs:string" />
	<xsl:variable name="annotation-root-id" as="xs:string" select="if ($root[1]/@eId) then $root[1]/@eId else local-name($root[1])" />
	<xsl:variable name="all-own-note-refs" as="element()*">
		<xsl:choose>
			<xsl:when test="$root[self::coverPage] or $root[self::preface] or $root[self::preamble]">
				<xsl:sequence select="$root//noteRef" />
			</xsl:when>
			<!-- when larger than section, only those not belonging to a descendant -->
			<xsl:when test="local:is-big-level($root)">
				<xsl:sequence select="$root/num//noteRef | $root/heading//noteRef | $root/subheading//noteRef |
					$root/intro//noteRef | $root/content//noteRef | $root/wrapUp//noteRef" />
			</xsl:when>
			<!-- when a section, everything -->
			<xsl:when test="local:is-p1($root)">
				<xsl:sequence select="$root//noteRef" />
			</xsl:when>
			<!-- when below a section, nothing -->
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="including-footnotes" select="$all-own-note-refs intersect $note-refs" />
	<xsl:variable name="own-note-refs" select="$including-footnotes[not(@class='footnote')]" />
	<xsl:if test="count($own-note-refs) > 0">
		<xsl:element name="{$wrapper-element-name}">
			<xsl:attribute name="class">annotations</xsl:attribute>
			<div>Annotations:</div>
			
			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'I')]" />
				<xsl:with-param name="heading" select="'Commencement Information'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'X')]" />
				<xsl:with-param name="heading" select="'Editorial Information'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'E')]" />
				<xsl:with-param name="heading" select="'Extent Information'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'F')]" />
				<xsl:with-param name="heading" select="'Amendments (Textual)'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'C')]" />
				<xsl:with-param name="heading" select="'Modifications etc. (not altering text)'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'M')]" />
				<xsl:with-param name="heading" select="'Marginal Citations'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>

			<xsl:call-template name="display-notes">
				<xsl:with-param name="note-refs" select="$own-note-refs[ends-with(@class,'P')]" />
				<xsl:with-param name="heading" select="'Subordinate Legislation Made'" />
				<xsl:with-param name="annotation-root-id" select="$annotation-root-id" tunnel="yes" />
			</xsl:call-template>
		</xsl:element>
	</xsl:if>
</xsl:template>

<xsl:template name="footnotes">
	<xsl:variable name="notes" as="element()*" select="/akomaNtoso/*/meta/notes/note[@class='footnote']" />
	<xsl:if test="exists($notes)">
		<footer class="footnotes">
			<xsl:for-each select="$notes">
				<xsl:variable name="id" as="xs:string" select="@eId" />
				<xsl:variable name="note-ref" as="element()?" select="key('note-ref', $id)[1]" />
				<xsl:if test="empty($note-ref)">
					<xsl:message>
						<xsl:text>can't find ref for footnote </xsl:text>
						<xsl:value-of select="$id" />
					</xsl:message>
				</xsl:if>
				<xsl:for-each select="$note-ref">
					<xsl:call-template name="display-note" />
				</xsl:for-each>
			</xsl:for-each>
		</footer>
	</xsl:if>
</xsl:template>


<!-- top level -->

<xsl:template match="coverPage">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
	<xsl:if test="$doc-category = 'primary'">
		<xsl:call-template name="annotations" />
	</xsl:if>
</xsl:template>

<xsl:template match="preface">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
	<xsl:if test="empty(following-sibling::preamble)">
		<xsl:call-template name="annotations">
			<xsl:with-param name="wrapper-element-name" select="'div'" />
		</xsl:call-template>
	</xsl:if>
</xsl:template>

<xsl:template match="preface/block[@name='title']">
	<h1>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</h1>
</xsl:template>

<xsl:template match="preface/block[@name=('number')]">
	<p>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="preamble">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
	<xsl:call-template name="annotations">
		<xsl:with-param name="root" select="preceding-sibling::preface | ." />
		<xsl:with-param name="wrapper-element-name" select="'div'" />
	</xsl:call-template>
</xsl:template>

<xsl:template match="body">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="conclusions | attachments | components">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="attachment">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="doc">
	<article>
		<xsl:apply-templates select="@name" />
		<xsl:variable name="category" as="xs:string?" select="meta/proprietary/ukm:*/ukm:DocumentClassification/ukm:DocumentCategory/@Value" />
		<xsl:if test="exists($category)">
			<xsl:attribute name="class">
				<xsl:value-of select="$category" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</article>
</xsl:template>

<!-- hierarchy -->

<!-- pure containers: part, chapter, crossheading -->

<xsl:template match="hcontainer[@name='group'] | title | part | chapter | hcontainer[@name='crossheading'] | hcontainer[@name='subheading'] | hcontainer[@name='P1group'] |
		hcontainer[@name='schedules'] | level">
	<section>
		<xsl:call-template name="attrs" />
		<xsl:if test="exists(num | heading | subheading)">
			<h2>
<!-- 				<xsl:if test="exists(num) and empty(heading | subheading)">
					<xsl:attribute name="class">
						<xsl:text>noheading</xsl:text>
					</xsl:attribute>
				</xsl:if> -->
				<xsl:apply-templates select="num | heading | subheading" />
			</h2>
		</xsl:if>
		<xsl:if test="empty(content) and empty(ancestor::quotedStructure)">
			<xsl:call-template name="annotations">
				<xsl:with-param name="wrapper-element-name" select="'header'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)]" />
		<xsl:if test="exists(content) and empty(ancestor::quotedStructure)">
			<xsl:call-template name="annotations">
				<xsl:with-param name="wrapper-element-name" select="'footer'" />
			</xsl:call-template>
		</xsl:if>
	</section>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule'] | hcontainer[@name='schedule']/part">
	<section>
		<xsl:call-template name="attrs" />
		<h2>
			<xsl:apply-templates select="num | heading | subheading" />
		</h2>
		<xsl:apply-templates select="num/authorialNote" />
		<xsl:if test="empty(content) and empty(ancestor::quotedStructure)">
			<xsl:call-template name="annotations">
				<xsl:with-param name="wrapper-element-name" select="'header'" />
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)]" />
		<xsl:if test="exists(content) and empty(ancestor::quotedStructure)">
			<xsl:call-template name="annotations">
				<xsl:with-param name="wrapper-element-name" select="'footer'" />
			</xsl:call-template>
		</xsl:if>
	</section>
</xsl:template>

<xsl:template match="hcontainer[@name='schedule']/num | hcontainer[@name='schedule']/part/num">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates select="node()[not(self::authorialNote)]" />
	</span>
</xsl:template>




<!-- P1 -->

<xsl:template match="section | article | hcontainer[@name='regulation'] | rule | hcontainer[@name='schedule']//paragraph[not(ancestor::paragraph)]">
	<section>
		<xsl:call-template name="attrs" />
		<h2>
<!-- 			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="empty(heading)">
						<xsl:text>no-heading</xsl:text>
					</xsl:when>
					<xsl:when test="*[1][self::num]">
						<xsl:text>num-heading</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>heading-num</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute> -->
			<xsl:apply-templates select="num | heading | subheading" />			
		</h2>
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)]">
			<xsl:with-param name="indent" select="1" tunnel="yes" />
		</xsl:apply-templates>
	</section>
	<xsl:if test="empty(ancestor::quotedStructure)">
		<xsl:call-template name="annotations" />
	</xsl:if>
</xsl:template>


<!-- P2 -->

<xsl:template match="subsection | subparagraph[ancestor::hcontainer[@name='schedule']][not(ancestor::subparagraph) and not(ancestor::paragraph/parent::paragraph)]">
	<section>
		<xsl:call-template name="attrs" />
		<h2>
			<xsl:apply-templates select="num | heading | subheading" />			
		</h2>
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)]">
			<xsl:with-param name="indent" select="2" tunnel="yes" />
		</xsl:apply-templates>
	</section>
</xsl:template>

<xsl:template match="paragraph | subparagraph | clause | subclause | point">
	<xsl:param name="indent" as="xs:integer" select="3" tunnel="yes" />
	<xsl:param name="plevel" as="xs:integer" select="3" tunnel="no" />
	<div>
		<xsl:call-template name="attrs" />
		<xsl:element name="h{$plevel}">
			<xsl:apply-templates select="num | heading | subheading" />			
		</xsl:element>
		<xsl:apply-templates select="intro" />
		<xsl:apply-templates select="*[not(self::num)][not(self::heading)][not(self::subheading)][not(self::intro)]">
			<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
			<xsl:with-param name="plevel" select="$plevel + 1" tunnel="no" />
		</xsl:apply-templates>
	</div>
</xsl:template>

<xsl:template match="num | heading | subheading">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="intro | content | wrapUp">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>


<!-- LISTS (ordered, unordered, and key) -->

<xsl:template match="item">
	<li>
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</li>
</xsl:template>

<xsl:template match="listIntroduction | listWrapUp">
	<li>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</li>
</xsl:template>

<!-- ordered lists -->

<xsl:template match="blockList[item/num]">
	<ol><xsl:apply-templates select="@*|node()"/></ol>
</xsl:template>

<xsl:template match="item/num">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:choose>
			<xsl:when test="@title">
				<xsl:attribute name="data-raw"><xsl:value-of select="." /></xsl:attribute>
				<xsl:value-of select="@title" />
				<xsl:apply-templates select="*" /><!-- for notes, etc -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose>
	</span>
</xsl:template>

<!-- unordered lists -->

<xsl:template match="blockList"><!-- [not(item/num)] -->
	<ul><xsl:apply-templates select="@*|node()"/></ul>
</xsl:template>

<!-- key lists -->

<xsl:template match="blockList[@class='key']">
	<dl>
		<xsl:if test="@ukl:separator = '='">
			<xsl:attribute name="class">equals</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="@*[name()!='class'][local-name()!='separator']" />
		<xsl:apply-templates />
	</dl>
</xsl:template>

<xsl:template match="blockList[@class='key']/item">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="blockList[@class='key']/item/heading">
	<dt><xsl:apply-templates select="@*|node()" /></dt>
</xsl:template>

<xsl:template match="blockList[@class='key']/item/*[not(self::heading)]" priority="1"><!-- could be another blockList -->
	<dd>
		<xsl:next-match />
	</dd>
</xsl:template>


<!-- blocks -->

<xsl:template match="p[docTitle] | p[shortTitle] | p[mod[quotedStructure]] | p[embeddedStructure] | p[subFlow] | p[authorialNote]">
	<div>
		<xsl:call-template name="attrs">
			<xsl:with-param name="classes" select="local-name()" />
		</xsl:call-template>
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="p">
	<p>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</p>
</xsl:template>

<xsl:template match="block[@name='figure']">
	<figure>
		<xsl:apply-templates select="@*[name() != 'name']" />
		<xsl:apply-templates />
	</figure>
</xsl:template>
<xsl:template match="tblock[@class='figure']">
	<figure>
		<xsl:apply-templates select="@*[name() != 'class']" />
		<xsl:apply-templates />
	</figure>
</xsl:template>
<xsl:template match="tblock[@class='figure']/heading">
	<figcaption>
		<xsl:apply-templates select="@*|node()" />
	</figcaption>
</xsl:template>

<xsl:template match="hcontainer | block | container | tblock | blockContainer | formula | longTitle | authorialNote | signatures | signature">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>


<xsl:template match="mod">
	<xsl:if test="preceding-sibling::node()[1][self::text()][normalize-space()]">
		<xsl:text> </xsl:text>
	</xsl:if>
	<xsl:choose>
		<xsl:when test="exists(child::quotedStructure)">
			<div class="mod">
				<xsl:apply-templates />
			</div>
		</xsl:when>
		<xsl:otherwise>
			<span class="mod">
				<xsl:apply-templates />
			</span>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="quotedStructure | embeddedStructure">
	<xsl:param name="indent" as="xs:integer" select="1" tunnel="yes" />
	<blockquote class="{ local-name() }">
		<xsl:apply-templates select="@* except (@startQuote, @endQuote)" />
		<xsl:variable name="text-nodes" as="text()*" select="descendant::text()[normalize-space()]" />
		<xsl:apply-templates>
			<xsl:with-param name="start-quote-attr" as="attribute()?" select="@startQuote" tunnel="yes" />
			<xsl:with-param name="end-quote-attr" as="attribute()?" select="@endQuote" tunnel="yes" />
			<xsl:with-param name="first-text-node-of-quote" select="$text-nodes[1]" tunnel="yes" />
			<xsl:with-param name="last-text-node-of-quote" select="$text-nodes[last()]" tunnel="yes" />
			<xsl:with-param name="append-text" select="following-sibling::*[1][@name='appendText']" tunnel="yes" />
			<xsl:with-param name="indent" select="$indent + 1" tunnel="yes" />
		</xsl:apply-templates>
	</blockquote>
</xsl:template>

<xsl:template match="inline[@name='appendText']" />


<!-- contents -->
<xsl:template match="toc">
	<div>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</div>
</xsl:template>

<xsl:template match="tocItem">
	<div class="{string-join((name(), @class), ' ')}">
		<xsl:apply-templates select="@*[not(name() = 'class')][not(name() = 'href')]" />
		<a>
			<xsl:apply-templates select="@href" />
			<xsl:apply-templates />
		</a>
	</div>
</xsl:template>


<!-- same -->

<xsl:template match="img">
	<xsl:element name="{local-name()}">
		<xsl:apply-templates select="@*" />
		<xsl:attribute name="alt"><xsl:value-of select="@alt" /></xsl:attribute>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="i | b | u | br | caption | tr | th | td | abbr | sup | sub |
	a | ol | ul | li | ins | del">
	<xsl:element name="{local-name()}"><xsl:apply-templates select="@*|node()" /></xsl:element>
</xsl:template>





<!-- foreign -->

<xsl:template match="foreign">
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="html:table">
	<xsl:param name="indent" as="xs:integer" select="0" tunnel="yes" />
	<xsl:element name="{ local-name() }">
		<xsl:copy-of select="@* except (@cols | @summary)" />
		<xsl:if test="$indent gt 0">
			<xsl:attribute name="class">
				<xsl:if test="exists(@class)">
					<xsl:value-of select="@class" />
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:text>level-</xsl:text>
				<xsl:value-of select="$indent" />
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates select="*[not(self::html:tfoot)]" />
		<xsl:apply-templates select="html:tfoot" />
	</xsl:element>
</xsl:template>

<xsl:template match="html:colgroup">
	<xsl:element name="{ local-name() }">
		<xsl:choose>
			<xsl:when test="exists(child::html:col)">
				<xsl:copy-of select="@* except @span" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="@*" />
			</xsl:otherwise>
		</xsl:choose>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="html:th | html:td | html:col">
	<xsl:element name="{ local-name() }">
		<xsl:copy-of select="@* except (@width, @align, @valign, @fo:*)" />
		<xsl:if test="exists(@width) or exists(@align) or exists(@valign) or exists(@fo:*)">
			<xsl:attribute name="style">
				<xsl:if test="exists(@style)">
					<xsl:value-of select="@style" />
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:if test="exists(@width)">
					<xsl:text>width:</xsl:text>
					<xsl:value-of select="@width"/>
					<xsl:if test="@width castable as xs:integer">
						<xsl:text>px</xsl:text>
					</xsl:if>
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:if test="exists(@align)">
					<xsl:text>text-align:</xsl:text>
					<xsl:value-of select="@align"/>
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:if test="exists(@valign)">
					<xsl:text>vertical-align:</xsl:text>
					<xsl:value-of select="@valign"/>
					<xsl:text>;</xsl:text>
				</xsl:if>
				<xsl:for-each select="@fo:*">
					<xsl:value-of select="local-name()"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>;</xsl:text>
				</xsl:for-each>
			</xsl:attribute>
		</xsl:if>
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="html:*">
	<xsl:element name="{ local-name() }">
		<xsl:copy-of select="@*" />
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>

<xsl:template match="math:math">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*"/>
		<xsl:choose>
			<xsl:when test="@altimg and not(math:semantics)">
				<semantics>
					<xsl:choose>
						<xsl:when test="every $child in * satisfies $child/self::math:mrow">
							<xsl:apply-templates />
						</xsl:when>
						<xsl:otherwise>
							<mrow>
								<xsl:apply-templates />
							</mrow>
						</xsl:otherwise>
					</xsl:choose>
					<annotation-xml encoding="MathML-Presentation">
						<mtext><img src="{ @altimg }" alt="math" /></mtext>
					</annotation-xml>
				</semantics>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates />
			</xsl:otherwise>
		</xsl:choose> 
	</xsl:element>
</xsl:template>

<xsl:template match="math:semantics">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*"/> 
		<xsl:apply-templates />
		<xsl:if test="../@altimg">
			<annotation-xml encoding="MathML-Presentation">
				<mtext><img src="{../@altimg}" alt="math" /></mtext>
			</annotation-xml>
		</xsl:if>
	</xsl:element>
</xsl:template>

<xsl:template match="math:*">
	<xsl:element name="{local-name()}">
		<xsl:copy-of select="@*" /> 
		<xsl:apply-templates />
	</xsl:element>
</xsl:template>



<!-- inline -->

<xsl:template match="inline">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="inline[@name='uppercase']">
	<span class="uppercase">
		<xsl:apply-templates select="@*" />
		<xsl:apply-templates />
	</span>
</xsl:template>

<xsl:template match="quotedText">
	<q>
		<xsl:apply-templates select="@*" />
		<xsl:value-of select="@startQuote" />
		<xsl:apply-templates />
		<xsl:value-of select="@endQuote" />
	</q>
</xsl:template>

<xsl:template match="noteRef">
	<xsl:choose>
		<xsl:when test="exists(ancestor::ref)">
			<span>
				<xsl:call-template name="add-class-attribute" />
				<xsl:apply-templates select="@* except (@href | @class)" />
				<xsl:value-of select="@marker" />
			</span>
			<xsl:text> </xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<a>
				<xsl:call-template name="attrs" />
				<xsl:value-of select="@marker" />
			</a>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="ref">
	<cite>
		<xsl:apply-templates select="@*[not(name()='href')]" />
		<xsl:choose>
			<xsl:when test=".//ref or parent::a">
				<xsl:attribute name="data-href"><xsl:value-of select="@href" /></xsl:attribute>
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:apply-templates select="@href" />
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</cite>
</xsl:template>

<xsl:template match="rref">
	<cite>
		<xsl:apply-templates select="@*" />
		<xsl:choose>
			<xsl:when test=".//ref">
				<xsl:apply-templates />
			</xsl:when>
			<xsl:otherwise>
				<a>
					<xsl:attribute name="href">
						<xsl:value-of select="@from" />
					</xsl:attribute>
					<xsl:apply-templates />
				</a>
			</xsl:otherwise>
		</xsl:choose>
	</cite>
</xsl:template>

<xsl:template match="date | docDate">
	<time>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</time>
</xsl:template>

<xsl:template match="span">
	<span>
		<xsl:apply-templates select="@*|node()" />
	</span>
</xsl:template>

<xsl:template match="*">
	<span>
		<xsl:call-template name="attrs" />
		<xsl:apply-templates />
	</span>
</xsl:template>


<!-- markers -->

<!-- eol -> <wbr> -->

<!-- attributes -->

<xsl:template match="@eId">
	<xsl:attribute name="id">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@date">
	<xsl:attribute name="datetime">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@class | @title | @style | @src | @alt | @width | @height | @colspan | @rowspan">
	<xsl:copy />
</xsl:template>

<xsl:template match="@href">
	<xsl:attribute name="href">
		<xsl:value-of select="replace(., ' ', '%20')" />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@xml:lang">
	<xsl:attribute name="{ local-name() }">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>

<xsl:template match="@*">
	<xsl:attribute name="data-{translate(name(), ':', '-')}">
		<xsl:value-of select="." />
	</xsl:attribute>
</xsl:template>


<!-- text nodes -->

<xsl:template match="text()">
	<xsl:param name="start-quote-attr" as="attribute()?" tunnel="yes" />
	<xsl:param name="end-quote-attr" as="attribute()?" tunnel="yes" />
	<xsl:param name="first-text-node-of-quote" as="text()?" tunnel="yes" />
	<xsl:param name="last-text-node-of-quote" as="text()?"  tunnel="yes" />
	<xsl:param name="append-text" as="element()?" tunnel="yes" />
	<xsl:if test="exists($start-quote-attr) and . is $first-text-node-of-quote">
		<xsl:value-of select="$start-quote-attr" />
	</xsl:if>
	<xsl:value-of select="." />
	<xsl:if test=". is $last-text-node-of-quote">
		<xsl:value-of select="$end-quote-attr" />
		<xsl:apply-templates select="$append-text/node()" />
	</xsl:if>
</xsl:template>

</xsl:stylesheet>
