package com.jurisdatum.tna.clml2akn;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.stream.StreamSource;

import com.jurisdatum.xml.Saxon;

import net.sf.saxon.s9api.Destination;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.Serializer.Property;
import net.sf.saxon.s9api.XsltCompiler;
import net.sf.saxon.s9api.XsltExecutable;
import net.sf.saxon.s9api.XsltTransformer;

public class Transform implements com.jurisdatum.xml.Transform {
	
	private static final String stylesheet = "/clml2akn/clml2akn.xsl";

	private static class Importer implements URIResolver {
		@Override public Source resolve(String href, String base) throws TransformerException {
			InputStream file = this.getClass().getResourceAsStream("/clml2akn/" + href);
			return new StreamSource(file);
		}
	}

	private final XsltExecutable executable;
	
	public Transform() throws IOException {
		XsltCompiler compiler = Saxon.processor.newXsltCompiler();
		compiler.setURIResolver(new Importer());
		InputStream stream = this.getClass().getResourceAsStream(stylesheet);
		Source source = new StreamSource(stream);
		try {
			executable = compiler.compile(source);
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		} finally {
			stream.close();
		}
	}
	
	public void transform(Source clml, Destination destination) {
		XsltTransformer transform = executable.load();
		try {
			transform.setSource(clml);
			transform.setDestination(destination);
			transform.transform();
		} catch (SaxonApiException e) {
			throw new RuntimeException(e);
		}
	}

	private static Properties properties = new Properties();
	static {
		properties.setProperty(Property.INDENT.toString(), "yes");
	}
	
	public void transform(Source clml, Result akn) {
		Destination destination = Saxon.makeDestination(akn, properties);
		transform(clml, destination);
	}

}
