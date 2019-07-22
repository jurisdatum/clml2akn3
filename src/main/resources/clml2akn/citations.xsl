<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs ukl local">


<xsl:function name="local:make-lgu-uri" as="xs:string">
	<xsl:param name="long-type" as="xs:string" />
	<xsl:param name="year" as="xs:string" />
	<xsl:param name="number" as="xs:string?" />
	<xsl:param name="section" as="xs:string?" />
	<xsl:variable name="short-type" as="xs:string" select="local:short-type-from-long($long-type)" />
	<xsl:variable name="host" as="xs:string" select="'http://www.legislation.gov.uk/'" />
	<xsl:choose>
		<xsl:when test="exists($section)">
			<xsl:value-of select="concat($host, 'id/', $short-type, '/', $year, '/', $number, '/', $section)" />
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat($host, 'id/', $short-type, '/', $year, '/', $number)" />
		</xsl:otherwise>
	</xsl:choose>
</xsl:function>

<xsl:template match="Citation">
	<xsl:choose>
		<xsl:when test="exists(@UpTo)">
			<rref>
				<xsl:apply-templates />
			</rref>
		</xsl:when>
		<xsl:otherwise>
			<ref eId="{ @id }">
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="exists(@URI)">
							<xsl:value-of select="@URI" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local:make-lgu-uri(@Class, @Year, @Number, @SectionRef)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:choose>
					<xsl:when test="node()[last()][self::FootnoteRef]"><!-- uksi/1999/1750/made -->
						<xsl:variable name="fnRef" as="element()" select="node()[last()]" />
							<xsl:apply-templates select="node() except $fnRef" />
						<xsl:apply-templates select="$fnRef" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates />
					</xsl:otherwise>
				</xsl:choose>
			</ref>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template match="CitationSubRef">
	<xsl:choose>
		<xsl:when test="exists(@StartSectionRef) and exists(@EndSectionRef)">
			<rref eId="{ @id }" class="subref">
				<xsl:attribute name="from">
					<xsl:choose>
						<xsl:when test="exists(@URI)">
							<xsl:value-of select="@URI" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local:make-lgu-uri(@Class, @Year, @Number, @StartSectionRef)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:attribute name="upTo">
					<xsl:choose>
						<xsl:when test="exists(@UpTo)">
							<xsl:value-of select="@UpTo" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local:make-lgu-uri(@Class, @Year, @Number, @EndSectionRef)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:if test="@CitationRef">
					<xsl:attribute name="ukl:CitationRef">
						<xsl:value-of select="@CitationRef" />
					</xsl:attribute>
				</xsl:if>
				<xsl:apply-templates />
			</rref>
		</xsl:when>
		<xsl:otherwise>
			<ref eId="{ @id }" class="subref">
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="exists(@URI)">
							<xsl:value-of select="@URI" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="local:make-lgu-uri(@Class, @Year, @Number, @SectionRef)" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:apply-templates />
			</ref>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>


</xsl:transform>
