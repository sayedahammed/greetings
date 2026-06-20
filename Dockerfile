# স্টেজ ১: Maven দিয়ে Java 25 অ্যাপ বিল্ড করা
FROM maven:3.9-eclipse-temurin-25-alpine AS builder
WORKDIR /build

# pom.xml কপি করে ডিপেন্ডেন্সি ক্যাশ করা
COPY pom.xml .
RUN mvn dependency:go-offline -B

# সোর্স কোড কপি করে JAR ফাইল তৈরি করা
COPY src ./src
RUN mvn clean package -DskipTests

# স্টেজ ২: আধুনিক jarmode=tools দিয়ে লেয়ারগুলো দক্ষ উপায়ে আনপ্যাক করা
FROM eclipse-temurin:25-jdk-alpine AS optimizer
WORKDIR /extractor

# builder স্টেজ থেকে তৈরি হওয়া JAR ফাইলটি কপি করা
COPY --from=builder /build/target/*.jar app.jar

# Spring Boot-এর আধুনিক উপায়ে লাইব্রেরি এবং অ্যাপ এক্সট্রাক্ট করা
RUN java -Djarmode=tools -jar app.jar extract --destination extracted

# স্টেজ ৩: চূড়ান্ত রানটাইম ইমেজ তৈরি (লাইটওয়েট ও সিকিউর JRE)
FROM eclipse-temurin:25-jre-alpine
WORKDIR /application

# সিকিউরিটির জন্য নন-রুট (Non-root) ইউজার তৈরি
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# আধুনিক লেআউট অনুযায়ী সমস্ত এক্সট্রাক্ট করা ফাইল একসাথে কপি করা
COPY --from=optimizer /extractor/extracted/ ./

EXPOSE 8080

# এক্সট্রাক্ট করা জারের নিজস্ব ক্লাসবাইন্ডিং অনুসারে স্ট্যান্ডার্ড জাভা কমান্ডে রান করা
ENTRYPOINT ["java", "-jar", "app.jar"]
