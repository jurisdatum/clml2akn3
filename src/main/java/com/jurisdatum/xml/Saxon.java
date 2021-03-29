package com.jurisdatum.xml;

import java.util.Properties;

import net.sf.saxon.Configuration;
import net.sf.saxon.s9api.Processor;
import net.sf.saxon.serialize.Emitter;

public class Saxon {

	public static final Processor processor = new Processor(false);

	public static class SerializerFactory extends net.sf.saxon.lib.SerializerFactory {

		public SerializerFactory(Configuration config) {
			super(config);
		}

		@Override
		protected Emitter newXMLEmitter(Properties properties) {
			return new XMLEmitter();
		}

	}

	public static class XMLEmitter extends net.sf.saxon.serialize.XMLEmitter {

		@Override
		protected String getAttributeIndentString() {
			return " ";
		}

	}

	static {
		Configuration configuration = processor.getUnderlyingConfiguration();
		SerializerFactory serializerFactory = new SerializerFactory(configuration);
		configuration.setSerializerFactory(serializerFactory);
	}

}
