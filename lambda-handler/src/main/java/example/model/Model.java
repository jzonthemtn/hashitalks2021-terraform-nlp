package example.model;

public class Model {

    private String modelID;
    private String image;
    private String progress;
    private String serviceArn;
    private String serviceName;
    private long startTime;

    public String getModelID() {
        return modelID;
    }

    public void setModelID(String modelID) {
        this.modelID = modelID;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getProgress() {
        return progress;
    }

    public void setProgress(String progress) {
        this.progress = progress;
    }

    public String getServiceArn() {
        return serviceArn;
    }

    public void setServiceArn(String serviceArn) {
        this.serviceArn = serviceArn;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public long getStartTime() {
        return startTime;
    }

    public void setStartTime(long startTime) {
        this.startTime = startTime;
    }

}
