<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">


<xsl:function name="local:is-within-schedule" as="xs:boolean">
	<xsl:param name="context" as="xs:string*" />
	<xsl:choose>
		<xsl:when test="empty($context)">
			<xsl:value-of select="false()" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:variable name="head" as="xs:string" select="$context[1]" />
			<xsl:choose>
				<xsl:when test="$head = 'schedule'">
					<xsl:value-of select="true()" />
				</xsl:when>
				<xsl:when test="$head = 'quotedStructure'">
					<xsl:value-of select="false()" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="local:is-within-schedule(subsequence($context, 2))" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:function name="local:make-hcontainer-name" as="xs:string?">
	<xsl:param name="clml" as="element()" />
	<xsl:param name="context" as="xs:string*" />
	<xsl:choose>
		<xsl:when test="$clml/self::P1 or $clml/self::P1group">
			<xsl:choose>
				<xsl:when test="local:is-within-schedule($context)">
					<xsl:text>paragraph</xsl:text>
				</xsl:when>
				<xsl:when test="$doc-category = 'primary'">
					<xsl:text>section</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$clml/self::P2">
			<xsl:choose>
				<xsl:when test="local:is-within-schedule($context)">
					<xsl:text>subparagraph</xsl:text>
				</xsl:when>
				<xsl:when test="$doc-category = 'primary'">
					<xsl:text>subsection</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$clml/self::P3">
			<xsl:choose>
				<xsl:when test="local:is-within-schedule($context)">
					<xsl:text>paragraph</xsl:text>
				</xsl:when>
				<xsl:when test="$doc-category = 'primary'">
					<xsl:text>paragraph</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$clml/self::P4">
			<xsl:choose>
				<xsl:when test="local:is-within-schedule($context)">
					<xsl:text>subparagraph</xsl:text>
				</xsl:when>
				<xsl:when test="$doc-category = 'primary'">
					<xsl:text>subparagraph</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
		<xsl:when test="$clml/self::P5">
			<xsl:choose>
				<xsl:when test="local:is-within-schedule($context)">
					<xsl:text>clause</xsl:text>
				</xsl:when>
				<xsl:when test="$doc-category = 'primary'">
					<xsl:text>clause</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:when>
	</xsl:choose>
</xsl:function>

</xsl:transform>
