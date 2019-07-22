<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">


<xsl:key name="change" match="Addition[not(ancestor::Footnote)] | Repeal[not(ancestor::Footnote)] | Substitution[not(ancestor::Footnote)]" use="@ChangeId" />

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
	<xsl:variable name="classes" as="xs:string*">
		<xsl:if test="self::Substitution">
			<xsl:sequence select="lower-case(local-name())" />
		</xsl:if>
		<xsl:sequence select="@ChangeId" />
		<xsl:if test=". is key('change', @ChangeId)[1]">
			<xsl:sequence select="'first'" />
		</xsl:if>
		<xsl:if test=". is key('change', @ChangeId)[last()]">
			<xsl:sequence select="'last'" />
		</xsl:if>
	</xsl:variable>
	<xsl:attribute name="class">
		<xsl:value-of select="string-join($classes, ' ')" />
	</xsl:attribute>
	<xsl:if test=". is key('change', @ChangeId)[1]">
		<xsl:apply-templates select="@CommentaryRef" />
	</xsl:if>
	<xsl:apply-templates />
</xsl:template>

<xsl:template match="@CommentaryRef">
	<xsl:variable name="commentary" as="element()?" select="key('id', .)" />
	<xsl:if test="empty($commentary)">
		<xsl:message>
			<xsl:text>commentary does not exist </xsl:text>
			<xsl:value-of select="." />
		</xsl:message>
	</xsl:if>
	<xsl:variable name="type" as="attribute()?" select="$commentary/@Type" />
	<noteRef href="#{.}">
		<xsl:if test="exists($type)">
			<xsl:attribute name="marker">
				<xsl:value-of select="$type" />
				<xsl:value-of select="local:get-commentary-num($type, .)" />
			</xsl:attribute>
		</xsl:if>
		<xsl:attribute name="class">
			<xsl:text>commentary</xsl:text>
			<xsl:if test="exists($type)">
				<xsl:text> </xsl:text>
				<xsl:value-of select="$type" />
			</xsl:if>
		</xsl:attribute>
	</noteRef>
</xsl:template>

</xsl:transform>
