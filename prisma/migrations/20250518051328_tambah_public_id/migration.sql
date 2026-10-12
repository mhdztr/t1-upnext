/*
  Warnings:

  - Added the required column `publicId` to the `Banner` table without a default value. This is not possible if the table is not empty.
  - Added the required column `publicId` to the `Document` table without a default value. This is not possible if the table is not empty.
  - Added the required column `publicId` to the `EventPhoto` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Banner" ADD COLUMN     "publicId" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "Document" ADD COLUMN     "publicId" TEXT NOT NULL;

-- AlterTable
ALTER TABLE "EventPhoto" ADD COLUMN     "publicId" TEXT NOT NULL;
