package example.model;

public class ModelTrainingRequest {

    private String name;
    private int epochs = 1;
    private String embeddings;
    private String image;

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

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }
}
