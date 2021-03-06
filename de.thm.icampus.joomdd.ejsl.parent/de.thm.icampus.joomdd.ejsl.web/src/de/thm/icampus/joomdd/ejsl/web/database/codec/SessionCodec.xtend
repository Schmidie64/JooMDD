package de.thm.icampus.joomdd.ejsl.web.database.codec

import de.thm.icampus.joomdd.ejsl.web.database.document.Session
import java.sql.Timestamp
import org.bson.BsonReader
import org.bson.BsonTimestamp
import org.bson.BsonWriter
import org.bson.codecs.Codec
import org.bson.codecs.DecoderContext
import org.bson.codecs.EncoderContext
import org.bson.codecs.configuration.CodecRegistry
import org.bson.types.ObjectId

/**
 * @author Wolf Rost
 */
class SessionCodec implements Codec<Session> {

    private CodecRegistry codecRegistry;

    new(CodecRegistry codecRegistry) {
        this.codecRegistry = codecRegistry;
    }

    override Session decode(BsonReader reader, DecoderContext decoderContext)
    {
        reader.readStartDocument();
        var ObjectId _id = reader.readObjectId;
        var ObjectId userID = reader.readObjectId("userID");
        var String sessionID = reader.readString("sessionID");
        var BsonTimestamp timestamp = reader.readTimestamp("timestamp");
        reader.readEndDocument();

        var Session session = new Session(userID, sessionID, new Timestamp(timestamp.time));
        return session;
    }

    override void encode(BsonWriter writer, Session session, EncoderContext encoderContext) {
        writer.writeStartDocument();
        writer.writeObjectId("userID", session.userID)
        writer.writeName("sessionID");
        writer.writeString(session.sessionID);
        writer.writeName("timestamp");
        writer.writeTimestamp(new BsonTimestamp(session.timestamp.time));
        writer.writeEndDocument();
    }

    override Class<Session> getEncoderClass() {
        return Session;
    }
}