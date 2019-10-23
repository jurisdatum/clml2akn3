package com.jurisdatum.tna.akn2html;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;

import com.jurisdatum.xml.Saxon;

import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer.Property;
import net.sf.saxon.s9api.XdmAtomicValue;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

public class Akn2Html {
	
	private final XsltExecutable executable;

	public Akn2Html() throws IOException {
		XsltCompiler compiler = Saxon.processor.newXsltCompiler();
		InputStream file = this.getClass().getResourceAsStream("/akn2html/akn2html.xsl");
		Source source = new StreamSource(file);
		try {
			executable = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			file.close();
		}
	}
	
	private void transform(Source akn, String cssPath, Destination destination) {
		XsltTransformer transform = executable.load();
		if (cssPath != null)
			transform.setParameter(new QName("css-path"), new XdmAtomicValue(cssPath));
		try {
			transform.setSource(akn);
			transform.setDestination(destination);
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
	}
	
	static Properties properties = new Properties();
	static {
		properties.setProperty(Property.METHOD.toString(), "html");
//		properties.setProperty(Property.VERSION.toString(), "5");
		properties.setProperty(Property.INCLUDE_CONTENT_TYPE.toString(), "no");
		properties.setProperty(Property.INDENT.toString(), "yes");
	}
	
	public void transform(Source akn, String cssPath, Result html) {
		Destination destination = Saxon.makeDestination(html, properties);
		transform(akn, cssPath, destination);
	}
	public void transform(Source akn, Result html) {
		transform(akn, null, html);
	}

}
