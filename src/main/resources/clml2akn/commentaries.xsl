<?xml version="1.0" encoding="utf-8"?>

<xsl:transform version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.legislation.gov.uk/namespaces/legislation"
	xmlns="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
	xmlns:local="http://www.jurisdatum.com/tna/clml2akn"
	exclude-result-prefixes="xs local">


<xsl:key name="commentary" match="Commentary" use="@id" />

<xsl:key name="commentary2" match="Commentary" use="@Type" />

<xsl:function name="local:get-commentary-num" as="xs:integer">
	<xsl:param name="type" as="attribute()" />
	<xsl:param name="id" as="xs:string" />
	<xsl:variable name="ids-of-type" as="xs:string*" select="key('commentary2', $type, root($type))/@id" />
	<xsl:value-of select="index-of($ids-of-type, $id)[1]" />
</xsl:function>


<xsl:template match="Commentaries" />

<xsl:template match="Commentary">
	<note>
		<xsl:attribute name="class">
			<xsl:value-of select="string-join(('commentary', @Type), ' ')" />
		</xsl:attribute>
		<xsl:attribute name="eId">
			<xsl:value-of select="@id" />
		</xsl:attribute>
		<xsl:apply-templates>
			<xsl:with-param name="context" select="'note'" tunnel="yes" />
		</xsl:apply-templates>
	</note>
</xsl:template>

<xsl:function name="local:get-first-element-after-commentary-ref" as="element()?">
	<xsl:param name="cref" as="element(CommentaryRef)" />
	<xsl:sequence select="$cref/following-sibling::*[not(self::CommentaryRef)][1]" />
</xsl:function>

<xsl:function name="local:should-skip-commentary-ref" as="xs:boolean">
	<xsl:param name="cref" as="element(CommentaryRef)" />
	<xsl:variable name="next-element" as="element()?" select="local:get-first-element-after-commentary-ref($cref)" />
	<xsl:value-of select="$next-element/self::Number or $next-element/self::Pnumber or $next-element/self::Title" />
</xsl:function>

<xsl:function name="local:get-skipped-commentary-refs" as="element(CommentaryRef)*">
	<xsl:param name="e" as="element()" />
	<xsl:sequence select="$e/preceding-sibling::CommentaryRef[local:get-first-element-after-commentary-ref(.) is $e]" />
</xsl:function>

<xsl:template match="CommentaryRef">
	<xsl:param name="force" as="xs:boolean" select="false()" />
	<xsl:if test="$force or not(local:should-skip-commentary-ref(.))">
		<noteRef href="#{@Ref}">
			<xsl:variable name="commentary" as="element()?" select="key('commentary', @Ref)[1]" />
			<xsl:if test="exists($commentary)">
				<xsl:attribute name="marker">
					<xsl:value-of select="$commentary/@Type" />
					<xsl:value-of select="local:get-commentary-num($commentary/@Type, @Ref)" />
				</xsl:attribute>
			</xsl:if>
			<xsl:attribute name="class">
				<xsl:value-of select="string-join(('commentary', $commentary/@Type), ' ')" />
			</xsl:attribute>
		</noteRef>
	</xsl:if>
</xsl:template>

</xsl:transform>
