<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:relpath="http://dita2indesign/functions/relpath"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:df="http://dita2indesign.org/dita/functions"
  xmlns:gmap="http://dita4publishers/namespaces/graphic-input-to-output-map"
  exclude-result-prefixes="xd df xs relpath gmap"
  version="2.0">
  
<!--  <xsl:import href="lib/relpath_util.xsl"/>-->
  
  <xsl:output name="ant" method="xml"
    indent="yes"
  />
  
  <xsl:template match="/" mode="generate-graphic-copy-ant-script">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template match="*[df:class(., 'map/map')]" mode="generate-graphic-copy-ant-script">
    <xsl:param name="graphicMap" as="element()" tunnel="yes"/>
    
    <xsl:variable name="resultUri" 
      select="relpath:newFile($outdir, 'copy-graphics.xml')" 
      as="xs:string"/>
    
    <xsl:message> + [INFO] Generating Ant graphic copying script as file "<xsl:sequence select="$resultUri"/>"...</xsl:message>
    
    <xsl:result-document format="ant" href="{$resultUri}">
      <xsl:apply-templates select="$graphicMap" mode="#current"/>
    </xsl:result-document>  
    <xsl:message> + [INFO] Ant graphic copying script generation done.</xsl:message>
  </xsl:template>
  
  <xsl:template match="gmap:graphic-map" mode="generate-graphic-copy-ant-script">
    
    
    <project name="graphics-copy" default="copy-graphics">
      <xsl:apply-templates mode="generate-copy-targets"/>
      <target name="copy-graphics">
        <echo message="Doing copy graphics..."/>
        <xsl:apply-templates mode="#current"/>
        <echo message="Copy graphics done."/>
      </target>
    </project>
  </xsl:template>
  
  <xsl:template match="gmap:graphic-map-item" mode="generate-graphic-copy-ant-script">
    <xsl:variable name="targetId" as="xs:string" 
      select="if (@id) then @id else concat('map-item-', position())" 
    />
    <antcall target="copy-{$targetId}"/>
  </xsl:template>
  
  <xsl:template match="gmap:graphic-map-item" mode="generate-copy-targets">
    <!--
      <gmap:graphic-map-item id="map-item-01"
        input-url="file:/Users/ekimber/workspace/dita4publishers/sample_data/epub-test/covers/images/1407-02.jpg"
        output-url="file:/Users/ekimber/workspace/dita4publishers/sample_data/epub-test/epub/images/1407-02.jpg"/>
    -->
    <xsl:variable name="targetId" as="xs:string" select="if (@id) then @id else concat('map-item-', position())"/>
    <xsl:variable name="sourceDir" 
      select="relpath:toFile(relpath:getParent(string(@input-url)), $platform)"/>
    <xsl:if test="false()">
      <xsl:message> + [DEBUG] graphic-map-item: $sourceDir="<xsl:sequence select="$sourceDir"/>"</xsl:message>
    </xsl:if>
    <xsl:variable name="toFile" select="relpath:toFile(string(@output-url), $platform)" as="xs:string"/>
    <xsl:message> + [INFO]   Mapping input graphic 
 + [INFO]      Input URL: <xsl:sequence select="string(@input-url)"/>
 + [INFO]    Target File: <xsl:sequence select="$toFile"/> 
    </xsl:message>
    <xsl:if test="false()">    
      <xsl:message> + [DEBUG] graphic-map-item: $toFile="<xsl:sequence select="$toFile"/>"</xsl:message>
    </xsl:if>
    
    <target name="check-{$targetId}">
      <condition property="is-{$targetId}">
        <available 
          filepath="{$sourceDir}"
          file="{relpath:getName(@input-url)}"
          />
      </condition>      
    </target>
    
    <target name="report-{$targetId}" unless="is-{$targetId}">
      <!-- FIXME: Instead of just reporting this, we could copy in a missing graphic file 
                  or even generate one using ImageMagick.
        -->
      <echo>[WARN] File <xsl:value-of select="@input-url"/> cannot be found. Will not be copied.</echo>
    </target>
    
    <target name="copy-{$targetId}" depends="check-{$targetId}, report-{$targetId}" if="is-{$targetId}">
      <copy toFile="{$toFile}" overwrite="yes"
      >
        <fileset dir="{$sourceDir}">
          <include name="{relpath:getName(@input-url)}"/>
        </fileset>
      </copy>      
    </target>
  </xsl:template>
  
</xsl:stylesheet>
