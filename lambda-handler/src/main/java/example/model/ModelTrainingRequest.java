package example.model;

public class ModelTrainingRequest {

    private String name;
    private int epochs = 1;
    private String embeddings = "distilbert-base-cased";

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getEpochs() {
        return epochs;
    }

    public void setEpochs(int epochs) {
        this.epochs = epochs;
    }

    public String getEmbeddings() {
        return embeddings;
    }

    public void setEmbeddings(String embeddings) {
        this.embeddings = embeddings;
    }

}
