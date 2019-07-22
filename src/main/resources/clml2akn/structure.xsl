<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">


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
			<hcontainer name="crossheading" class="p1group">
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

<xsl:template match="P1">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" select="local:make-hcontainer-name(., $context)" />
	<xsl:element name="{ $name }">
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

<xsl:template match="P2 | P3 | P4 | P5">
	<xsl:param name="context" as="xs:string*" tunnel="yes" />
	<xsl:variable name="name" select="local:make-hcontainer-name(., $context)" />
	<xsl:element name="{ $name }">
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
