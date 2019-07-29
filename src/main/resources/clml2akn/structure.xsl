<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:html="http://www.w3.org/1999/xhtml"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs html local">


<xsl:variable name="mapping" as="element()">
	<Legislation xmlns="">
		<primary>
			<P1 akn="section" />
			<P2 akn="subsection" />
			<P3 akn="paragraph" />
			<P4 akn="subparagraph" />
			<P5 akn="clause" />
			<P6 akn="subclause" />
		</primary>
		<secondary>
			<order>
				<P1 akn="article" />
				<P2 akn="paragraph" />
				<P3 akn="subparagraph" />
				<P4 akn="clause" />
				<P5 akn="subclause" />
				<P6 akn="point" />
			</order>
			<regulation>
				<P1 akn="regulation" />
				<P2 akn="paragraph" />
				<P3 akn="subparagraph" />
				<P4 akn="clause" />
				<P5 akn="subclause" />
				<P6 akn="point" />
			</regulation>
			<rule>
				<P1 akn="rule" />
				<P2 akn="paragraph" />
				<P3 akn="subparagraph" />
				<P4 akn="clause" />
				<P5 akn="subclause" />
				<P6 akn="point" />
			</rule>
		</secondary>
		<schedule>
			<P1 akn="paragraph" />
			<P2 akn="subparagraph" />
			<P3 akn="paragraph" class="para1" />
			<P4 akn="subparagraph" class="para2" />
			<P5 akn="clause" />
			<P6 akn="subclause" />
		</schedule>
		<euretained>
		</euretained>
	</Legislation>
</xsl:variable>

<xsl:function name="local:make-hcontainer-name" as="xs:string?">
	<xsl:param name="doc-class" as="xs:string" />
	<xsl:param name="doc-subclass" as="xs:string" />
	<xsl:param name="schedule" as="xs:boolean" />
	<xsl:param name="clml-element-name" as="xs:string" />
	<xsl:choose>
		<xsl:when test="$schedule">
			<xsl:value-of select="$mapping/*:schedule/*[local-name()=$clml-element-name]/@akn" />
		</xsl:when>
		<xsl:when test="$doc-class = 'secondary'">
			<xsl:value-of select="$mapping/*:secondary/*[local-name()=$doc-subclass]/*[local-name()=$clml-element-name]/@akn" />
		</xsl:when>
		<xsl:when test="$doc-class = 'euretained'">
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="$mapping/*:primary/*[local-name()=$clml-element-name]/@akn" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:clml-is-within-schedule" as="xs:boolean">
	<xsl:param name="clml" as="element()" />
	<xsl:choose>
		<xsl:when test="empty($clml/parent::*)">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:when test="$clml/parent::Schedule">
			<xsl:value-of select="true()" />
		</xsl:when>
		<xsl:when test="$clml/parent::BlockAmendment">
			<xsl:value-of select="$clml/parent::*/@Context = 'schedule'" />
		</xsl:when>
		<xsl:when test="$clml/parent::html:td">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="local:clml-is-within-schedule($clml/parent::*)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:make-hcontainer-name" as="xs:string?">
	<xsl:param name="clml" as="element()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:variable name="block-amendment" as="element()?" select="$clml/ancestor::BlockAmendment[1]" />
	<xsl:variable name="doc-class" as="xs:string">
		<xsl:choose>
			<xsl:when test="exists($block-amendment)">
				<xsl:value-of select="$block-amendment/@TargetClass" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$doc-category" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="doc-subclass" as="xs:string?">
		<xsl:choose>
			<xsl:when test="exists($block-amendment)">
				<xsl:value-of select="$block-amendment/@TargetSubClass" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$doc-minor-type" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="within-schedule" as="xs:boolean">
		<xsl:choose>
			<xsl:when test="local:clml-is-within-schedule($clml)">
				<xsl:sequence select="true()" />
			</xsl:when>
			<xsl:when test="exists($block-amendment)">
				<xsl:sequence select="$block-amendment/@Context = 'schedule'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="clml-element-name" as="xs:string">
		<xsl:choose>
			<xsl:when test="ends-with(local-name($clml), 'group')">
				<xsl:value-of select="substring-before(local-name($clml), 'group')" />
			</xsl:when>
			<xsl:when test="$clml/self::P/parent::Pblock">
				<xsl:value-of select="'P1'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="local-name($clml)" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:value-of select="local:make-hcontainer-name($doc-class, $doc-subclass, $within-schedule, $clml-element-name)" />
</xsl:function>


<xsl:function name="local:struct-has-structural-children" as="xs:boolean">
	<xsl:param name="parent" as="element()" />
	<xsl:variable name="paras" as="element()*" select="$parent/*[local:element-is-para(.)]" />
	<xsl:value-of select="exists($parent/*[local:element-is-structural(.)]) or exists($paras/*[local:element-is-structural(.)])" />
</xsl:function>

<xsl:function name="local:flatten-children" as="element()*">
	<xsl:param name="parent" as="element()" />
	<xsl:for-each select="$parent/*">
		<xsl:choose>
			<xsl:when test="self::Number or self::Pnumber or self::Title or self::Subtitle" />
			<xsl:when test="local:element-is-para(.)">
				<xsl:sequence select="local:flatten-children(.)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="." />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
</xsl:function>

<xsl:function name="local:get-intro-elements" as="element()*">
	<xsl:param name="children" as="element()*" />
	<xsl:if test="exists($children)">
		<xsl:variable name="first-child" as="element()" select="$children[1]" />
		<xsl:if test="not(local:element-is-structural($first-child))">
			<xsl:sequence select="($first-child, local:get-intro-elements(subsequence($children, 2)))" />
		</xsl:if>
	</xsl:if>
</xsl:function>

<xsl:function name="local:get-wrapup-elements" as="element()*">
	<xsl:param name="children" as="element()*" />
	<xsl:if test="exists($children)">
		<xsl:variable name="last-child" as="element()" select="$children[last()]" />
		<xsl:if test="not(local:element-is-structural($last-child))">
			<xsl:sequence select="(local:get-wrapup-elements($children[position() lt last()]), $last-child)" />
		</xsl:if>
	</xsl:if>
</xsl:function>

<xsl:template name="hcontainer-body">
	<xsl:choose>
		<xsl:when test="local:struct-has-structural-children(.)">
			<xsl:variable name="children" as="element()+" select="local:flatten-children(.)" />
			<xsl:variable name="intro" as="element()*" select="local:get-intro-elements($children)" />
			<xsl:variable name="wrapup" as="element()*" select="local:get-wrapup-elements($children)" />
			<xsl:if test="exists($intro)">
				<intro>
					<xsl:apply-templates select="$intro" />
				</intro>
			</xsl:if>
			<xsl:apply-templates select="$children except $intro except $wrapup" />
			<xsl:if test="exists($wrapup)">
				<wrapUp>
					<xsl:apply-templates select="$wrapup" />
				</wrapUp>
			</xsl:if>
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="headings" as="element()*" select="Number | Pnumber | Title | Subtitle" />
			<content>
				<xsl:apply-templates select="* except $headings" />
			</content>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="hcontainer">
	<xsl:apply-templates select="Number | Pnumber" />
	<xsl:if test="self::P1 and parent::P1group and empty(parent::*/parent::*/P1group[count(P1) gt 1])">
		<xsl:apply-templates select="parent::*/Title" />
	</xsl:if>
	<xsl:if test="self::P2 and parent::P2group and empty(parent::*/parent::*/P2group[count(P2) gt 1])">
		<xsl:apply-templates select="parent::*/Title" />
	</xsl:if>
	<xsl:apply-templates select="Title | Subtitle" />
	<xsl:call-template name="hcontainer-body" />
</xsl:template>

<xsl:template match="Part">
	<part>
		<xsl:call-template name="hcontainer" />
	</part>
</xsl:template>

<xsl:template match="Chapter">
	<chapter>
		<xsl:call-template name="hcontainer" />
	</chapter>
</xsl:template>

<xsl:template match="Pblock">
	<hcontainer name="crossheading">
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="P1group">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(parent::*/P1group[count(P1) gt 1])">
			<hcontainer name="crossheading">  <!-- class="p1group" -->
				<xsl:apply-templates>
					<xsl:with-param name="context" select="('crossheading', $context)" tunnel="yes" />
				</xsl:apply-templates>
			</hcontainer>
		</xsl:when>
		<xsl:when test="empty(P1)">
			<xsl:if test="exists(*[local:element-is-structural(.)])">
				<xsl:message terminate="yes">
					<xsl:sequence select="." />
				</xsl:message>
			</xsl:if>
			<xsl:variable name="name" as="xs:string" select="local:make-hcontainer-name(., $context)" />
			<xsl:element name="{ $name }">
				<xsl:if test="normalize-space(Title)">
					<xsl:apply-templates select="Title">
						<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
					</xsl:apply-templates>
				</xsl:if>
				<xsl:call-template name="hcontainer-body">
					<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
				</xsl:call-template>
			</xsl:element>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="*[not(self::Title)]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:variable name="unsupported" as="xs:string*" select="('regulation')" />

<xsl:template match="P1">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" select="local:make-hcontainer-name(., $context)" />
	<xsl:element name="{ if ($name = $unsupported) then 'hcontainer' else $name }">
		<xsl:if test="$name = $unsupported">
			<xsl:attribute name="name">
				<xsl:value-of select="$name" />
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="hcontainer">
			<xsl:with-param name="context" select="($name, $context)" tunnel="yes" />
		</xsl:call-template>
	</xsl:element>
</xsl:template>

<xsl:template match="P2group">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:choose>
		<xsl:when test="exists(parent::*/P2group[count(P2) gt 1])">
			<level>
				<xsl:apply-templates />
			</level>
		</xsl:when>
		<xsl:otherwise>
			<xsl:apply-templates select="*[not(self::Title)]" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="P2 | P3 | P4 | P5 | Pblock/P">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" select="local:make-hcontainer-name(., $context)" />
	<xsl:element name="{ $name }">
		<!-- add the LDAPP class attributes where necessary -->
		<xsl:if test="self::P3 and local:clml-is-within-schedule(.) and exists(ancestor::BlockAmendment)">
			<xsl:attribute name="class">
				<xsl:text>para1</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:if test="self::P4 and local:clml-is-within-schedule(.) and exists(ancestor::BlockAmendment)">
			<xsl:attribute name="class">
				<xsl:text>para2</xsl:text>
			</xsl:attribute>
		</xsl:if>
		<xsl:call-template name="hcontainer" />
	</xsl:element>
</xsl:template>

<xsl:template match="P">
	<xsl:apply-templates />
</xsl:template>


<!-- schedules -->

<xsl:template match="Schedules">
	<hcontainer name="schedules">
		<xsl:apply-templates />
	</hcontainer>
</xsl:template>

<xsl:template match="Schedule">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<hcontainer name="schedule">
		<xsl:apply-templates select="*[not(self::Reference)]">
			<xsl:with-param name="context" select="('schedule', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</hcontainer>
</xsl:template>

<xsl:template match="ScheduleBody">
	<xsl:call-template name="hcontainer-body" />
</xsl:template>

<xsl:template match="Schedule/Number">
	<num>
		<xsl:apply-templates />
		<xsl:apply-templates select="../Reference" />
	</num>
</xsl:template>

<xsl:template match="Reference">
	<authorialNote class="referenceNote">
		<p>
			<xsl:apply-templates />
		</p>
	</authorialNote>
</xsl:template>


<!-- numbers and headings -->

<xsl:template match="Number | Pnumber">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<num>
		<xsl:apply-templates select="local:get-skipped-commentary-refs(.)">
			<xsl:with-param name="force" select="true()" />
		</xsl:apply-templates>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('num', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</num>
</xsl:template>

<xsl:template match="Title">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<heading>
		<xsl:apply-templates select="local:get-skipped-commentary-refs(.)">
			<xsl:with-param name="force" select="true()" />
		</xsl:apply-templates>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="('heading', $context)" tunnel="yes" />
		</xsl:apply-templates>
	</heading>
</xsl:template>

<xsl:template match="TitleBlock">
	<xsl:apply-templates />
</xsl:template>

</xsl:transform>
