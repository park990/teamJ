package com.teamj.util;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Optional;
import java.util.UUID;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import com.amazonaws.services.s3.AmazonS3Client;
import com.amazonaws.services.s3.model.PutObjectRequest;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RequiredArgsConstructor
@Component
public class S3Uploader {
    private final AmazonS3Client amazonS3Client;

    @Value("${cloud.aws.s3.bucket}")
    private String bucket;

    // 이미지 업로드(Service에서 호출)
    public String upload(MultipartFile multipartFile, String dirName){
        try{
            // S3에 보내기 위해서는 실제 파일로 하드디스크에 저장되어 있어야함. mutipartfile객체를 file로 변환 
            File uploadFile = convert(multipartFile).orElseThrow(()->new IllegalArgumentException("MultipartFile -> File 전환 실패"));
            
            return uploadToS3(uploadFile, dirName);
        
        }catch(IOException e){
            throw new RuntimeException("이미지 업로드 실패", e);
        }
    }

    private String uploadToS3(File uploadFile, String dirName){
        String fileName= dirName + "/" + UUID.randomUUID() + "-" + uploadFile.getName();

        // 실제로 업로드는 하는데 위에서 만든 파일의 이름과 post라는 dirName으로 만든 이름으로 upload파일을 실제 S3에 저장한다.
        String uploadImageUrl = putS3(fileName, uploadFile);

        removeNewFile(uploadFile);

        return uploadImageUrl;
    }

    private String putS3(String fileName, File uploadFile) {
        amazonS3Client.putObject(new PutObjectRequest(bucket, fileName, uploadFile));
        return amazonS3Client.getUrl(bucket, fileName).toString();
    }
    
    private void removeNewFile(File targetFile) {
        if (targetFile.delete()) {
            log.info("로컬 파일이 삭제되었습니다.");
        } else {
            log.info("로컬 파일이 삭제되지 못했습니다.");
        }
    }


    // 로컬 파일 변환
    private Optional<File> convert(MultipartFile file) throws IOException{

        // 파일 객체 생성
        File convertFile = new File(System.getProperty("user.dir")+"/"+file.getOriginalFilename());
        
        // 이미 존재 한다면 삭제
        if(convertFile.exists()){
            convertFile.delete();
        }

        // 로컬에 새 파일 생성 
        if(convertFile.createNewFile()){
            // 생성된 파일에 write.
            try(FileOutputStream fos = new FileOutputStream(convertFile)){
                fos.write(file.getBytes());
            }
            return Optional.of(convertFile); 
        }
        return Optional.empty();
    } 
}
