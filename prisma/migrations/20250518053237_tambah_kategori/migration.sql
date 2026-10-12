/*
  Warnings:

  - Added the required column `category` to the `Event` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "EventCategory" AS ENUM ('SEMINAR', 'WORKSHOP', 'WEBINAR', 'KOMPETISI', 'PELATIHAN', 'FESTIVAL', 'PENTAS_SENI', 'BAKTI_SOSIAL', 'MUSYAWARAH', 'REUNI', 'KAMPANYE', 'PAMERAN', 'KAJIAN', 'PERINGATAN_HARI_BESAR', 'LAUNCHING', 'OTHER');

-- AlterTable
ALTER TABLE "Event" ADD COLUMN     "category" "EventCategory" NOT NULL;
