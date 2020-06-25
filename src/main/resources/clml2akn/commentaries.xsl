<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:uk="https://www.legislation.gov.uk/namespaces/UK-AKN"
	xmlns:ukl="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs uk ukl local">


<xsl:template match="Commentaries" />

<xsl:template match="Commentaries" mode="metadata">

	<xsl:variable name="all-unique-commentary-ids-in-reference-order" as="xs:string*">
		<xsl:variable name="all-elements" as="element()*" select="( //CommentaryRef | //*[exists(@CommentaryRef)] )" />
		<xsl:variable name="all-commentary-ids-with-duplicates" as="xs:string*">
			<xsl:for-each select="$all-elements">
				<xsl:choose>
					<xsl:when test="self::CommentaryRef">
						<xsl:sequence select="string(@Ref)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:sequence select="string(@CommentaryRef)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>
		<xsl:for-each-group select="$all-commentary-ids-with-duplicates" group-by=".">
			<xsl:sequence select="." />
		</xsl:for-each-group>
	</xsl:variable>
	
	<xsl:variable name="all-commentaries-in-reference-order" as="element(Commentary)*">
		<xsl:variable name="root" as="document-node()" select="root()" />
		<xsl:for-each select="$all-unique-commentary-ids-in-reference-order">
			<xsl:sequence select="key('id', ., $root)" />
		</xsl:for-each>
	</xsl:variable>
	
	<notes source="#">
		<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='I']" />
		<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='X']" />
		<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='E']" />
		<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='F']" />
		<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='C']" />
		<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='M']" />
		<xsl:apply-templates select="$all-commentaries-in-reference-order[@Type='P']" />
	</notes>
</xsl:template>

<xsl:template match="Commentary">
	<note ukl:Name="Commentary" ukl:Type="{ @Type }">
		<xsl:attribute name="class">
			<xsl:text>commentary </xsl:text>
			<xsl:value-of select="@Type" />
		</xsl:attribute>
		<xsl:attribute name="eId">
			<xsl:value-of select="@id" />
		</xsl:attribute>
		<xsl:attribute name="marker">
			<xsl:value-of select="@Type" />
			<xsl:value-of select="position()" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'note'" tunnel="yes" />
		</xsl:apply-templates>
	</note>
</xsl:template>

<xsl:template match="Part | Chapter | Pblock | PsubBlock" mode="other-analysis">
	<xsl:variable name="id" as="xs:string" select="@id" />
	<xsl:variable name="all-commentary-ids-with-duplicates" as="xs:string*">
		<xsl:variable name="all-elements" as="element()*" select="( self::*[exists(@CommentaryRef)] | child::CommentaryRef | Number/descendant-or-self::*[exists(@CommentaryRef)] | Number/descendant::CommentaryRef | Title/descendant-or-self::*[exists(@CommentaryRef)] | Title/descendant::CommentaryRef )" />
		<xsl:for-each select="$all-elements">
			<xsl:choose>
				<xsl:when test="self::CommentaryRef">
					<xsl:sequence select="string(@Ref)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="string(@CommentaryRef)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:for-each-group select="$all-commentary-ids-with-duplicates" group-by=".">
		<uk:commentary href="#{ $id }" refersTo="#{ . }" />
	</xsl:for-each-group>
	<xsl:apply-templates mode="other-analysis" />
</xsl:template>

<xsl:template match="P1" mode="other-analysis">
	<xsl:variable name="id" as="xs:string" select="@id" />
	<xsl:variable name="all-commentary-ids-with-duplicates" as="xs:string*">
		<xsl:variable name="all-elements" as="element()*" select="( descendant-or-self::*[exists(@CommentaryRef)] | descendant::CommentaryRef )" />
		<xsl:for-each select="$all-elements">
			<xsl:choose>
				<xsl:when test="self::CommentaryRef">
					<xsl:sequence select="string(@Ref)" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="string(@CommentaryRef)" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</xsl:variable>
	<xsl:for-each-group select="$all-commentary-ids-with-duplicates" group-by=".">
		<uk:commentary href="#{ $id }" refersTo="#{ . }" />
	</xsl:for-each-group>
</xsl:template>

<xsl:template match="BlockAmendment | EmbeddedStructure" mode="other-analysis" />

<xsl:template match="node()" mode="other-analysis">
	<xsl:apply-templates mode="other-analysis" />
</xsl:template>

<xsl:template match="CommentaryRef">
	<xsl:variable name="commentary" as="element(Commentary)?" select="key('id', @Ref)" />
	<xsl:if test="exists($commentary) and $commentary/@Type = ('F', 'M', 'X')">
		<noteRef href="#{ @Ref }" uk:name="commentary" ukl:Name="CommentaryRef" class="commentary" />
	</xsl:if>
</xsl:template>

</xsl:transform>
