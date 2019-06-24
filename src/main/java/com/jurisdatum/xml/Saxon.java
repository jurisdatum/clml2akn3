package com.jurisdatum.xml;

import java.util.Properties;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.serialize.Emitter;

public class Saxon {
	
	private static class XMLEmitter extends net.sf.saxon.serialize.XMLEmitter {
		@Override
	    protected String getAttributeIndentString() {
	        return " ";
	    }
	}
	
	private static class SerializerFactory extends net.sf.saxon.lib.SerializerFactory {
		public SerializerFactory() {
			super(new Configuration());
		}
		@Override
		protected Emitter newXMLEmitter(Properties properties) {
			return new XMLEmitter();
		}
	}
	
	private static final SerializerFactory serializerFactory = new SerializerFactory();
	
	private static class Configuration extends net.sf.saxon.Configuration {
		@Override
		public SerializerFactory getSerializerFactory() {
			return serializerFactory;
		}
	}

	private static final Configuration configuration = new Configuration();

	public static final Processor processor = new Processor(configuration);
	
}
