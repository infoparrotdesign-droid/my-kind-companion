// @ts-nocheck
import { createFileRoute } from "@tanstack/react-router";
import { ArrowRight, Bell, BriefcaseBusiness, Check, Clipboard, ClipboardList, Edit3, Filter, ImagePlus, Laptop, Mail, Menu, MessageCircle, Minus, Package, Palette, Phone, Plus, Printer, RefreshCw, Search, ShoppingBag, ShoppingCart, Sparkles, Star, Trash2, Upload, X, ZoomIn, ZoomOut } from "lucide-react";
import { useEffect, useMemo, useRef, useState, type ChangeEvent, type PointerEvent } from "react";
import { supabase } from "@/integrations/supabase/client";

const ADMIN_EMAIL = "info.parrotdesign@gmail.com";
const IMAGE_BUCKET = "parrot-images";

export const Route = createFileRoute("/")({ component: Index });
type Category = "Papelaria" | "Informática";
type Product = { id:string; name:string; category:Category; description:string; price:number; code:string; stock:number; available:boolean; image?:string };
type Service = { id?:string; type:string; title:string; description:string; image?:string|null; created_at?:string; updated_at?:string };
type PortfolioPreview = { t:string; c:string; tone:string; image?:string|null; description?:string; client?:string|null; year?:number|null };
type PortfolioProject = { id:string; title:string; category:string; description:string; image?:string|null; client?:string|null; project_year?:number|null; featured:boolean; sort_order:number; created_at?:string; updated_at?:string };\ntype CustomerReview = { id:string; customer_name:string; company?:string|null; rating:number; comment:string; approved:boolean; created_at:string; updated_at:string };